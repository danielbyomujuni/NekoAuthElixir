ARG ELIXIR_VERSION=1.18.3
ARG OTP_VERSION=25.3.2.21
ARG DEBIAN_VERSION=buster-20240612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN npm install -g yarn

# prepare build dir
WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# This used to be above COPY config step, but doing so broke the workspace system
RUN cd assets && yarn install

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

RUN mix release
RUN ls _build/prod
RUN ls /app/_build/prod

COPY /app/_build/${MIX_ENV}/rel /app_build/${MIX_ENV}/rel

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}


WORKDIR "/app"


RUN chown neko /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=neko:root /app/_build/${MIX_ENV}/rel/neko_auth ./

USER neko

CMD ["/app/bin/server"]
