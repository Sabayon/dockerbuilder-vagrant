#!/bin/bash
export ACCEPT_LICENSE=*

equo up && sudo equo u
equo i docker vixie-cron git wget curl net-analyzer/netcat6 git-lfs e2fsprogs sys-fs/xfsprogs docker-companion molecule-plugins molecule-core net-misc/rysnc www-servers/nginx
echo -5 | equo conf update

git lfs install

cp -rfv /vagrant/confs/rsyncd.conf /etc/rsyncd.conf
cp -rfv /vagrant/confs/nginx.conf /etc/nginx/nginx.conf
sed -i 's:txt;:txt log;:g' /etc/nginx/mime.types
mkdir /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=IT/ST=Italy/L=Internet/O=Sabayon/OU=Builders/CN=sabayon.org"

systemctl enable rsyncd
systemctl start rsyncd

systemctl enable docker
systemctl start docker
cp -rfv /vagrant/build.service /etc/systemd/system/
cp -rfv /vagrant/setup.sh /opt/setup.sh
systemctl daemon-reload
systemctl enable build
systemctl start build
systemctl enable vixie-cron
systemctl start vixie-cron
systemctl enable nginx
systemctl start nginx
crontab /vagrant/crontab
echo "@@@@ Do docker login if necessary."
