#!/usr/bin/env bash

crontabfile=$mydotfiles/crontab.cron
who=`whoami`

echo "Installing crontab ${crontabfile}..."
echo "sudo crontab -u ${who} $crontabfile"
sudo crontab -u $who $crontabfile
crontab -l
