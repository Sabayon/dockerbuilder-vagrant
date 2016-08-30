#!/bin/bash
export ACCEPT_LICENSE=*

equo up && sudo equo u
equo i docker vixie-cron git wget curl net-analyzer/netcat6 git-lfs e2fsprogs sys-fs/xfsprogs docker-companion molecule-plugins molecule-core rysnc
echo -5 | equo conf update

git lfs install

cp -rfv /vagrant/confs/rsyncd.conf /etc/rsyncd.conf


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
crontab /vagrant/crontab
echo "@@@@ Do docker login if necessary."
