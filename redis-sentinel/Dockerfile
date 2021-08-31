FROM redis:latest

LABEL maintainer="shizhice <shizhice@bayeasy.cn>"

COPY redis.tmpl /redis-conf/redis.tmpl
COPY sentinel.tmpl /redis-conf/sentinel.tmpl
COPY generate-supervisor-conf.sh /generate-supervisor-conf.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get update -y && apt-get install -y procps supervisor gettext-base

VOLUME /data

EXPOSE 7100 7101 7102  17100 17101 17102

ENTRYPOINT ["/docker-entrypoint.sh", "redis-sentinel"]
