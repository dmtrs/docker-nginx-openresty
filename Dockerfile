FROM debian:wheezy


RUN apt-get update \
    && apt-get install -y libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make curl

ENV OPENRESTY_VERSION 1.7.10.1

ADD ngx_openresty-${OPENRESTY_VERSION}.tar.gz /root/

RUN cd /root/ngx_openresty-${OPENRESTY_VERSION} \
    && ./configure --prefix=/opt/openresty --with-http_gunzip_module --with-luajit \
    --with-luajit-xcflags=-DLUAJIT_ENABLE_LUA52COMPAT \
    --http-client-body-temp-path=/var/lib/nginx/client_body_temp \
    --http-proxy-temp-path=/var/lib/nginx/proxy_temp \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/lib/nginx/nginx.pid \
    --lock-path=/var/lib/nginx/nginx.lock \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-file-aio \
    && make \
    && make install \
    && rm -rf /root/ngx_openresty* \
    && ln -sf /opt/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && ln -sf /usr/local/bin/nginx /usr/local/bin/openresty \
    && ln -sf /opt/openresty/bin/resty /usr/local/bin/resty

RUN ln -sf /opt/openresty/luajit/bin/luajit-2.1.0-alpha /opt/openresty/luajit/bin/lua \
    && ln -sf /opt/openresty/luajit/bin/lua /usr/local/bin/lua

ENV LUAROCKS_VERSION 2.2.0
ADD luarocks-${LUAROCKS_VERSION}.tar.gz /tmp/

RUN  cd /tmp/luarocks-${LUAROCKS_VERSION} \
    && ./configure --with-lua=/opt/openresty/luajit \
    --with-lua-include=/opt/openresty/luajit/include/luajit-2.1 \
    --with-lua-lib=/opt/openresty/lualib \
    && make && make install \
    && rm -rf /tmp/luarocks-*

ADD nginx.conf /etc/nginx/
CMD [ "/usr/local/bin/nginx", "-p", "/root", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;" ]
