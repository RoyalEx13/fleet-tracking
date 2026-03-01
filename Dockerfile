FROM erlang:28-alpine AS build

RUN apk add --no-cache elixir build-base git nodejs npm

WORKDIR /app

ARG MIX_ENV
ENV MIX_ENV=${MIX_ENV:-dev}

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock* ./

RUN mix deps.get --only $MIX_ENV

RUN if [ -d "deps/langchain" ]; then \
      sed -i 's/get_in(req_body)/get_in(req_body, [])/g' deps/langchain/lib/chat_models/chat_google_ai.ex; \
    fi

COPY . .

RUN mix compile

CMD ["sh", "-c", "mix deps.get && mix ash.setup && mix phx.server"]