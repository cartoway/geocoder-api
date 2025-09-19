FROM ruby:3.2-bookworm
ENTRYPOINT []
CMD ["/bin/bash"]

VOLUME /srv/app/poly

ENV REDIS_HOST redis-cache

RUN apt update && \
    apt install -y \
        libsqlite3-mod-spatialite

WORKDIR /srv/app
ADD ./Gemfile /srv/app/
ADD ./Gemfile.lock /srv/app/
RUN bundle install --full-index --without test development
ADD . /srv/app

EXPOSE 80

HEALTHCHECK \
    --start-interval=1s \
    --start-period=30s \
    --interval=30s \
    --timeout=20s \
    --retries=5 \
    CMD wget --no-verbose --tries=1 -O /dev/null http://127.0.0.1:80/ping || exit 1
