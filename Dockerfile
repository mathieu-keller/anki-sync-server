# ---- build ----
FROM rust:1.89.0 AS build-env
WORKDIR /app

# Will be provided by buildx
ARG TARGETARCH

# Needed for MUSL builds
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends protobuf-compiler libprotobuf-dev musl-tools ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Map Docker arch -> Rust MUSL target triple
RUN case "$TARGETARCH" in \
      "amd64")  echo x86_64-unknown-linux-musl  > /rust-target.txt ;; \
      "arm64")  echo aarch64-unknown-linux-musl > /rust-target.txt ;; \
      *)        echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac
RUN rustup target add "$(cat /rust-target.txt)"

# Allow bidi control codepoints in generated i18n (fixes the build on newer Rust)
ENV RUSTFLAGS="-Atext_direction_codepoint_in_literal --cap-lints=warn"
ENV CARGO_TERM_COLOR=never
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Build the sync server for the computed MUSL target
RUN cargo install --locked \
      --git https://github.com/ankitects/anki.git \
      --tag 25.07.5 \
      anki-sync-server \
      --target "$(cat /rust-target.txt)"

# ---- runtime ----
FROM gcr.io/distroless/static-debian12:nonroot@sha256:e8a4044e0b4ae4257efa45fc026c0bc30ad320d43bd4c1a7d5271bd241e386d0

ARG NOW

LABEL org.opencontainers.image.created=$NOW \
      org.opencontainers.image.title="Unofficial Anki Sync Server" \
      org.opencontainers.image.description="An unofficial Docker image for the Anki Sync Server, automatically built from the Anki source code. It uses Rust to build the server and is optimized for minimal runtime dependencies with a Distroless base image." \
      org.opencontainers.image.authors="Mathieu Keller" \
      org.opencontainers.image.url="https://github.com/mathieu-keller/anki-sync-server" \
      org.opencontainers.image.source="https://github.com/ankitects/anki/tree/main" \
      org.opencontainers.image.documentation="https://docs.ankiweb.net/sync-server.html" \
      org.opencontainers.image.version="25.09.2" \
      org.opencontainers.image.revision="25.09.2" \
      org.opencontainers.image.licenses="GNU AGPL-3.0-or-later" \
      org.opencontainers.image.vendor="Ankitects (Original Source Code); Docker Image by Mathieu Keller" \
      org.opencontainers.image.base.name="gcr.io/distroless/static-debian12:nonroot" org.opencontainers.image.base.digest="sha256:e8a4044e0b4ae4257efa45fc026c0bc30ad320d43bd4c1a7d5271bd241e386d0"

# cargo installs to /usr/local/cargo/bin regardless of --target
COPY --from=build-env /usr/local/cargo/bin/anki-sync-server /anki-sync-server

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
CMD ["/anki-sync-server", "--healthcheck"]

CMD ["/anki-sync-server"]
