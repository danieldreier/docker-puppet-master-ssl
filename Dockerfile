FROM danieldreier/wheezy-puppet-agent
MAINTAINER Daniel Dreier <ddreier@thinkplango.com>

# run using
# docker build -t danieldreier/ssl-data-example .
# docker run --rm -e "AWS_ACCESS_KEY_ID=XXXX" -e "AWS_SECRET_ACCESS_KEY=XXXXX" -e "S3BUCKET=dockertest1" -t -i --name=puppetmaster-ssl-data danieldreier/ssl-data-example
VOLUME /var/lib/puppet/ssl
RUN mkdir -p /var/lib/puppet/ssl

RUN apt-get update && apt-get install -y inotify-tools python-pip
RUN pip install awscli
ADD sync.sh /root/sync.sh
ADD inotify_watch.sh /root/inotify_watch.sh
RUN chmod +x /root/inotify_watch.sh /root/sync.sh
# if you use ENTRYPOINT or other CMD format exit signal isn't detected correctly
# you have to run /root/sync.sh directly in the docker run command
