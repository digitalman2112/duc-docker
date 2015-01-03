#!/bin/sh
/usr/local/bin/duc index /data  &
# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/*

/usr/sbin/apache2ctl -D FOREGROUND