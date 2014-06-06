#!/bin/sh

/etc/init.d/corosync stop
killall -9 corosync
sleep 2
rm -rf /var/lib/heartbeat/crm/*

