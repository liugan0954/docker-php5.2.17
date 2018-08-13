FROM centos:6.9

MAINTAINER liugan0954@qq.com

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#COPY etc/yum.repos.d/nginx.repo /etc/yum.repos.d/nginx.repo
#RUN yum install -y nginx
#COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf

#COPY php-5.2.17_el6.x86_64.tar.gz /tmp
#RUN tar xf /tmp/php-5.2.17_el6.x86_64.tar.gz -C /usr/local && rm -f /tmp/php-5.2.17_el6.x86_64.tar.gz
#COPY etc/init.d/php-fpm /etc/init.d/php-fpm
#RUN useradd --home-dir /usr/local/php-5.2.17/var/lib/php --create-home --user-group --shell /sbin/nologin --comment "PHP-FPM User" php

#拷贝软件
ADD apr-1.5.2.tar.bz2 /tmp
ADD apr-util-1.5.4.tar.bz2 /tmp
ADD httpd-2.2.31.tar.bz2 /tmp
ADD libmcrypt-2.5.7.tar.gz /tmp
ADD pcre-8.36.tar.gz /tmp
ADD php-5.2.17.tar.bz2 /tmp
 

RUN yum install -y epel-release \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 \
    && yum install -y gcc gcc-c++ make libtool libxml2-devel openssl-devel bzip2-devel curl-devel libjpeg-devel libpng-devel freetype-devel openldap-devel mysql-devel postgresql-devel libtool-ltdl-devel
 
RUN groupadd -g 503 it
RUN useradd -u 500 -g it oracle

RUN cd /tmp/apr-1.5.2 \
&& ./configure --prefix=/ap/apr \
&& make && make install \
&& cd ../apr-util-1.5.4 \
&& ./configure --prefix=/ap/apr-util --with-apr=/ap/apr \
&& make && make install \
&& cd ../pcre-8.36 \
&& ./configure --prefix=/ap/pcre \
&& make && make install \
&& cd ../httpd-2.2.31 \
&& ./configure --prefix=/ap/ora --with-apr=/ap/apr --with-apr-util=/ap/apr-util  --with-pcre=/ap/pcre  ap_cv_void_ptr_lt_long=no \
&& make && make install \
&& cd ../libmcrypt-2.5.7 \
&& ./configure \
&& make && make install \
&& ln -s /usr/lib64/libjpeg.so.62 /usr/lib/libjpeg.so \
&& ln -s /usr/lib64/libpng.so.3.49.0 /usr/lib/libpng.so \
&& cp -frp /usr/lib64/libldap* /usr/lib/ \
&& cd ../php-5.2.17 \
&& ./configure --prefix=/ap/php \
     --with-apxs2=/ap/ora/bin/apxs \
	 --with-config-file-path=/ap/ora/conf \
	 --with-zlib \
	 --with-bz2 \
	 --enable-sigchild \
	 --with-gettext \
	 --with-gd \
	 --with-png-dir \
	 --with-jpeg-dir \
	 --with-freetype-dir \
	 --without-pear \
	 --with-openssl \
	 --enable-soap \
	 --enable-mbstring \
	 --with-ldap \
	 --with-ldap-sasl \
	 --without-sqlite \
	 --without-pdo-sqlite \
	 --enable-sockets \
	 --with-mcrypt=/usr/local/libmcrypt \
	 --with-curl \
	 --enable-exif \
	 --enable-zip \
	 --with-pdo-mysql \
	 --with-mysqli \
	 --with-pdo-pgsql \
&& make && make install

# 配置站点
COPY etc/apache/httpd.conf /ap/ora/conf/httpd.conf
COPY etc/php/php.ini /ap/ora/conf/php.ini

# 建立documentroot 目录 并建立测试页
RUN mkdir -p /php \
    && echo '<?php phpinfo(); ?>' > /php/index.php \
    && chown -R oracle:it /php

# 清除yum 缓存
RUN yum clean all
# copy 脚本至 容器中
COPY usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# 修改执行脚本的权限
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh /php/index.php
# 容器 已守护容器开启
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# 映射端口
EXPOSE 80 8080
