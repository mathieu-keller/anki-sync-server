FROM rust:1.88.0 as build-env
WORKDIR /app

RUN apt update \
    && apt upgrade -y \
    && apt install -y protobuf-compiler libprotobuf-dev musl-tools \
    && rustup target add x86_64-unknown-linux-musl

RUN cargo install --git https://github.com/ankitects/anki.git --tag 25.07.5 anki-sync-server --target x86_64-unknown-linux-musl


FROM gcr.io/distroless/static-debian12:nonroot@sha256:627d6c5a23ad24e6bdff827f16c7b60e0289029b0c79e9f7ccd54ae3279fb45f

ARG NOW

LABEL org.opencontainers.image.created=$NOW \
      org.opencontainers.image.title="Unofficial Anki Sync Server" \
      org.opencontainers.image.description="An unofficial Docker image for the Anki Sync Server, automatically built from the Anki source code. It uses Rust to build the server and is optimized for minimal runtime dependencies with a Distroless base image." \
      org.opencontainers.image.authors="Mathieu Keller" \
      org.opencontainers.image.url="https://github.com/mathieu-keller/anki-sync-server" \
      org.opencontainers.image.source="https://github.com/ankitects/anki/tree/main" \
      org.opencontainers.image.documentation="https://docs.ankiweb.net/sync-server.html" \
      org.opencontainers.image.version="25.07.5" \
      org.opencontainers.image.revision="25.07.5" \
      org.opencontainers.image.licenses="GNU AGPL-3.0-or-later" \
      org.opencontainers.image.vendor="Ankitects (Original Source Code); Docker Image by Mathieu Keller" \
      org.opencontainers.image.base.name="gcr.io/distroless/static-debian12:nonroot" org.opencontainers.image.base.digest="sha256:627d6c5a23ad24e6bdff827f16c7b60e0289029b0c79e9f7ccd54ae3279fb45f"

COPY --from=build-env /usr/local/cargo/bin/anki-sync-server /

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
CMD ["/anki-sync-server", "--healthcheck"]

CMD ["/anki-sync-server"]
