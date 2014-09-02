#!/bin/bash

SYNC_INTERVAL=300 #seconds between s3 sync runs

function cleanup {
  echo "Exit detected, running final sync..."
  aws s3 sync /var/lib/puppet/ssl s3://${S3BUCKET}
  exit
}

sync() {
  aws s3 sync s3://${S3BUCKET} /var/lib/puppet/ssl
  aws s3 sync /var/lib/puppet/ssl s3://${S3BUCKET}
}
sync
bash /root/inotify_watch.sh &

while :; do
        trap cleanup SIGTERM SIGHUP SIGINT EXIT SIGQUIT
        echo "Syncing..."
        sync
        sleep $SYNC_INTERVAL &
        PID=$!
        wait $PID 2>/dev/null
done
