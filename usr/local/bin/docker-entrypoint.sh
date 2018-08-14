#!/bin/sh

#/sbin/service php-fpm start
#/usr/sbin/nginx

/ap/ora/bin/apachectl start

# 保持前台运行，不退出
while true
do
    sleep 100
done
