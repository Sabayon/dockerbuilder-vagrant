#!/bin/bash

systemctl stop docker
rm -rfv /var/lib/docker
systemctl start docker
