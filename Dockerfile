FROM rust:1.83.0 as build-env
WORKDIR /app
RUN apt update \
    && apt upgrade -y \
    && apt install -y protobuf-compiler libprotobuf-dev \
    && cargo install --git https://github.com/ankitects/anki.git --tag 24.11 anki-sync-server

FROM gcr.io/distroless/cc-debian12:nonroot@sha256:594b5200fd1f06d17a877ebee16d4af84a9a7ab83c898632a2d5609c0593cbab

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
      org.opencontainers.image.base.name="gcr.io/distroless/cc-debian12:nonroot" org.opencontainers.image.base.digest="sha256:594b5200fd1f06d17a877ebee16d4af84a9a7ab83c898632a2d5609c0593cbab"


COPY --from=build-env /usr/local/cargo/bin/anki-sync-server /
CMD ["/anki-sync-server"]
