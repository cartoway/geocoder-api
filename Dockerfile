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
