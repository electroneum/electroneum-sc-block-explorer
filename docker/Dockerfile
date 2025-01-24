FROM bitwalker/alpine-elixir-phoenix:1.13

RUN apk --no-cache --update add alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3 file qemu-x86_64

ENV GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION=2.30-r0

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
        do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

# Get Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="$HOME/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-feature=-crt-static"

EXPOSE 4000

# Default to production environment
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}
ENV PORT=4000 \
    SECRET_KEY_BASE="RMgI4C1HSkxsEjdhtGMfwAHfyT6CKWXOgzCboJflfSm4jeAlic52io05KB6mqzc5"

# Cache Elixir dependencies
ADD mix.exs mix.lock ./
ADD apps/block_scout_web/mix.exs ./apps/block_scout_web/
ADD apps/explorer/mix.exs ./apps/explorer/
ADD apps/ethereum_jsonrpc/mix.exs ./apps/ethereum_jsonrpc/
ADD apps/indexer/mix.exs ./apps/indexer/

RUN HEX_HTTP_TIMEOUT=600 mix do deps.get, local.rebar --force, deps.compile

# Add the full codebase
ADD . .

# Conditional asset compilation based on the environment
RUN if [ "$MIX_ENV" = "prod" ]; then \
      npm install --prefix ./apps/block_scout_web/assets && \
      npm run deploy --prefix ./apps/block_scout_web/assets && \
      mix phx.digest; \
    else \
      echo "Skipping asset compilation for development"; \
    fi

# Customizable runtime argument for COIN customization
ARG COIN
RUN if [ "$COIN" != "" ]; then \
        sed -i s/"Electroneum"/"${COIN}"/g apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po; \
        sed -i "/msgid \"ETN\"/{n;s/msgstr \"\"/msgstr \"${COIN}\"/g}" apps/block_scout_web/priv/gettext/default.pot; \
        sed -i "/msgid \"ETN\"/{n;s/msgstr \"\"/msgstr \"${COIN}\"/g}" apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po; \
        sed -i "/msgid \"ETN\"/{n;s/msgstr \"\"/msgstr \"${COIN}\"/g}" apps/block_scout_web/priv/gettext/default.pot; \
        sed -i "/msgid \"ETN\"/{n;s/msgstr \"\"/msgstr \"${COIN}\"/g}" apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po; \
    fi

# Final build compilation
RUN mix compile

# Ensure npm is up-to-date
RUN npm install npm@latest

# Add npm dependencies for Blockscout
RUN cd apps/block_scout_web/assets/ && \
    npm install && \
    cd -

RUN cd apps/explorer/ && \
    npm install && \
    apk update && apk del --force-broken-world alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3

RUN apk add --update git make
RUN export "CFLAGS=-I/usr/local/include -L/usr/local/lib" && cd deps/ex_secp256k1 && mix deps.get && mix compile

# Default command for running the application
CMD ["sh", "-c", "mix phx.server"]