#!/bin/bash
# Watch for changes in a directory and sync them to S3
# The S3BUCKET, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY environment
# variables must be set for this to work
EVENTS="CREATE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"
WATCHDIR="/var/lib/puppet/ssl"

aws s3 sync s3://${S3BUCKET} $WATCHDIR
sync() {
  EVENT="$1"
  case "$EVENT" in
    DELETE)
      aws s3 sync --delete $WATCHDIR s3://${S3BUCKET}
      ;;
    *)
      aws s3 sync $WATCHDIR s3://${S3BUCKET}
      aws s3 sync s3://${S3BUCKET} $WATCHDIR
      ;;
  esac
}

watch() {
  inotifywait -e "$EVENTS" -m -r --format '%:e %f' $WATCHDIR
}

watch | (
while true ; do
  read -t 1 LINE && sync $LINE
  unset LINE
done
)
