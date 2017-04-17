FROM gargron/mastodon

RUN apk add --no-cache redis postgresql curl
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu
RUN apk del curl && rm -rf /var/cache/apk/*

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data
ENV REDIS_PORT 6379
ENV DB_USER postgres
ENV DB_NAME postgres
ENV DB_PASS ''
ENV DB_PORT 5432

COPY docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]

