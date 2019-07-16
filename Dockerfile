# STEP 1 - RELEASE BUILDER
FROM elixir:1.9-alpine AS builder

# setup up variables
ARG APP_NAME
ARG APP_VSN
ARG PHOENIX_SUBDIR=.

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} 

# make directory
RUN mkdir /app
WORKDIR /app

# This step installs all the build tools we'll need
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    nodejs \
    npm \
    build-base && \
    npm i -g yarn && \
    mix local.rebar --force && \
    mix local.hex --force

# install rebar and hex
RUN mix local.rebar --force
RUN mix local.hex --force

# elixir create diretories
ENV MIX_ENV=prod
RUN mkdir \ 
    /app/_build/ \
    /app/config/ \
    /app/lib/ \
    /app/priv/ \ 
    /app/deps/ \
    /app/rel/ \
    /app/assets

# install deps and compile deps
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock
RUN mix do deps.get --only $MIX_ENV, deps.compile
RUN mix compile

# assets -- install javascript deps
COPY assets/package.json /app/assets/package.json
COPY assets/yarn.lock /app/assets/yarn.lock
RUN cd ${PHOENIX_SUBDIR}/assets && \
    yarn install && \
    cd -

# assets -- build assets
COPY assets /app/assets
RUN cd ${PHOENIX_SUBDIR}/assets && \
    yarn deploy && \
    cd -

# copy config, priv and release directories
COPY config /app/config
COPY priv /app/priv
COPY rel /app/rel
RUN mix phx.digest

# copy application code
COPY lib /app/lib

# create release
RUN mkdir -p /opt/built &&\
    mix release --verbose &&\
    cp _build/prod/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built &&\
    cd /opt/built &&\ 
    tar -xzf ${APP_NAME}.tar.gz &&\
    rm ${APP_NAME}.tar.gz

################################################################################
## STEP 2 - FINAL
FROM alpine:3.9

ENV MIX_ENV=prod

RUN apk update && \
    apk add --no-cache \
    bash \
    openssl-dev

COPY --from=builder /opt/built /app
WORKDIR /app
