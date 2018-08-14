FROM centos:6.9

MAINTAINER liugan0954@qq.com

#RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#COPY etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
#RUN yum install -y nginx
#COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf

#COPY php-5.2.17_el6.x86_64.tar.gz /tmp
#RUN tar xf /tmp/php-5.2.17_el6.x86_64.tar.gz -C /usr/local && rm -f /tmp/php-5.2.17_el6.x86_64.tar.gz
#COPY etc/init.d/php-fpm /etc/init.d/php-fpm
#RUN useradd --home-dir /usr/local/php-5.2.17/var/lib/php --create-home --user-group --shell /sbin/nologin --comment "PHP-FPM User" php

#拷贝软件
ADD php5.2.17-mod.tar.gz /
 

RUN yum install -y epel-release \
    && yum install -y gcc gcc-c++ make libtool libxml2-devel openssl-devel bzip2-devel curl-devel libjpeg-devel libpng-devel freetype-devel openldap-devel mysql-devel postgresql-devel libtool-ltdl-devel
 

RUN groupadd -g 503 it \
&& useradd -u 500 -g it oracle \
&& ln -s /usr/lib64/libjpeg.so.62 /usr/lib/libjpeg.so \
&& ln -s /usr/lib64/libpng.so.3.49.0 /usr/lib/libpng.so \
&& cp -frp /usr/lib64/libldap* /usr/lib/


# 配置站点
COPY etc/apache/httpd.conf /ap/ora/conf/httpd.conf
COPY etc/php/php.ini /ap/ora/conf/php.ini
COPY usr/local/lib/libmcrypt.so.4 /usr/local/lib/
# copy 脚本至 容器中
COPY usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# 建立documentroot 目录 并建立测试页
RUN mkdir -p /php \
    && echo '<?php phpinfo(); ?>' > /php/index.php \
    && chown -R oracle:it /php \
    # 清除yum 缓存
    && yum clean all \
# 修改执行脚本的权限
    &&  chmod 755 /usr/local/bin/docker-entrypoint.sh /php/index.php
# 容器 已守护容器开启
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# 映射端口
EXPOSE 80 8080
