FROM rust:1.84.1 as build-env
WORKDIR /app

RUN apt update \
    && apt upgrade -y \
    && apt install -y protobuf-compiler libprotobuf-dev musl-tools \
    && rustup target add x86_64-unknown-linux-musl

RUN cargo install --git https://github.com/ankitects/anki.git --tag 24.11 anki-sync-server --target x86_64-unknown-linux-musl


FROM gcr.io/distroless/static-debian12:nonroot@sha256:6ec5aa99dc335666e79dc64e4a6c8b89c33a543a1967f20d360922a80dd21f02

ARG NOW

LABEL org.opencontainers.image.created=$NOW \
      org.opencontainers.image.title="Unofficial Anki Sync Server" \
      org.opencontainers.image.description="An unofficial Docker image for the Anki Sync Server, automatically built from the Anki source code. It uses Rust to build the server and is optimized for minimal runtime dependencies with a Distroless base image." \
      org.opencontainers.image.authors="Mathieu Keller" \
      org.opencontainers.image.url="https://github.com/mathieu-keller/anki-sync-server" \
      org.opencontainers.image.source="https://github.com/ankitects/anki/tree/main" \
      org.opencontainers.image.documentation="https://docs.ankiweb.net/sync-server.html" \
      org.opencontainers.image.version="24.11" \
      org.opencontainers.image.revision="24.11" \
      org.opencontainers.image.licenses="GNU AGPL-3.0-or-later" \
      org.opencontainers.image.vendor="Ankitects (Original Source Code); Docker Image by Mathieu Keller" \
      org.opencontainers.image.base.name="gcr.io/distroless/static-debian12:nonroot" org.opencontainers.image.base.digest="sha256:6ec5aa99dc335666e79dc64e4a6c8b89c33a543a1967f20d360922a80dd21f02"

COPY --from=build-env /usr/local/cargo/bin/anki-sync-server /

HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
CMD ["/anki-sync-server", "--healthcheck"]

CMD ["/anki-sync-server"]
