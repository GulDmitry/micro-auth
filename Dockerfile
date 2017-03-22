FROM openresty/openresty:alpine-fat

MAINTAINER Sebastian Ruml <sebastian@sebastianruml.name>

RUN apk add --update \
    openssl-dev bash \
    git \
    && rm /var/cache/apk/*

RUN /usr/local/openresty/luajit/bin/luarocks install luasec
RUN /usr/local/openresty/luajit/bin/luarocks install lapis
RUN /usr/local/openresty/luajit/bin/luarocks install penlight
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-jwt
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-cookie

RUN mkdir /app

WORKDIR /app

ADD ./app /app

ENV LAPIS_OPENRESTY "/usr/local/openresty/bin/openresty"

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["server", "production"]
