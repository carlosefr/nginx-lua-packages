#
# Dockerfile
#
# Base nginx image including a recent OpenSSL library for proper ALPN
# support with HTTP/2. Also includes the Lua module (with LuaJIT) and
# a couple of useful smaller modules from OpenResty.
#


FROM debian:8


RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libpcre3 zlib1g

# Install build dependencies...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl gcc make libpcre3-dev zlib1g-dev

RUN mkdir /tmp/nginx-build
WORKDIR /tmp/nginx-build

ENV LUAJIT_VERSION 2.0.4
RUN curl -sL "http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz" | tar zxf - && \
    make -C LuaJIT-${LUAJIT_VERSION} amalg PREFIX="/usr/local" && \
    make -C LuaJIT-${LUAJIT_VERSION} install PREFIX="/usr/local" && \
    rm -rf LuaJIT-${LUAJIT_VERSION}

ENV OPENSSL_VERSION 1.0.2h
RUN curl -sL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" | tar zxf -

ENV NGINX_VERSION 1.11.3
RUN curl -sL "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar zxf -

ENV SET_MISC_VERSION 0.31
RUN curl -sL "https://github.com/openresty/set-misc-nginx-module/archive/v${SET_MISC_VERSION}.tar.gz" | tar zxf -

ENV HEADERS_MORE_VERSION 0.31
RUN curl -sL "https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz" | tar zxf -

ENV NGX_DEVEL_KIT_VERSION 0.3.0
RUN curl -sL "https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz" | tar zxf -

ENV NGX_LUA_VERSION 0.10.6
RUN curl -sL "https://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_VERSION}.tar.gz" | tar zxf -

RUN useradd -U -r nginx

RUN cd nginx-${NGINX_VERSION} && \
    LUAJIT_LIB="/usr/local/lib" \
    LUAJIT_INC="/usr/local/include/luajit-$(echo $LUAJIT_VERSION | cut -d. -f1-2)" \
    ./configure --prefix=/usr/share/nginx \
                --conf-path=/etc/nginx/nginx.conf \
                --sbin-path=/usr/sbin/nginx \
                --pid-path=/var/run/nginx.pid \
                --lock-path=/var/run/nginx.lock \
                --http-log-path=/var/log/nginx/access.log \
                --error-log-path=/var/log/nginx/error.log \
                --http-client-body-temp-path=/var/cache/nginx/client_temp \
                --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
                --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
                --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
                --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
                --user=nginx \
                --group=nginx \
                --with-ld-opt="-Wl,--strip-debug,-rpath,${LUAJIT_LIB}" \
                --with-openssl=../openssl-${OPENSSL_VERSION} \
                --add-module=../ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
                --add-module=../lua-nginx-module-${NGX_LUA_VERSION} \
                --add-module=../set-misc-nginx-module-${SET_MISC_VERSION} \
                --add-module=../headers-more-nginx-module-${HEADERS_MORE_VERSION} \
                --with-file-aio \
                --with-http_auth_request_module \
                --with-http_gunzip_module \
                --with-http_slice_module \
                --with-http_ssl_module \
                --with-http_stub_status_module \
                --with-http_v2_module \
                --with-ipv6 \
                --with-threads \
                --with-stream \
                --with-stream_ssl_module \
                --with-pcre-jit && \
    make && make install && \
    mkdir -m 770 /var/cache/nginx && chown root:nginx /var/cache/nginx

# Remove all build-related artifacts...
RUN apt-get -qq -y purge curl gcc make libpcre3-dev zlib1g-dev && \
    apt-get -qq -y autoremove && \
    apt-get -qq -y autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && rm -rf nginx-build

WORKDIR /usr/share/nginx/html


EXPOSE 80
EXPOSE 443

# This does nothing and must be overridden...
CMD ["nginx", "-g", "daemon off; user nginx;"]


# vim: set ts=4 sw=4 expandtab:
