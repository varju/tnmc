#!/bin/sh

mysqldump -u tnmc -ppassword tnmc --opt | gzip -c > /tmp/tnmc.sql.gz
