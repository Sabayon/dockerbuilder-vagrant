#!/bin/bash

systemctl stop docker
rm -rfv /var/lib/docker
systemctl start docker
equo up 
equo u
echo -5 | equo conf update
