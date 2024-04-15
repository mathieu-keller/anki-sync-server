FROM rust:1.77.2 as build-env
WORKDIR /app
RUN apt update \
    && apt upgrade -y \
    && apt install -y protobuf-compiler libprotobuf-dev \
    && cargo install --git https://github.com/ankitects/anki.git --tag 24.04.1 anki-sync-server

FROM gcr.io/distroless/cc-debian12:nonroot
COPY --from=build-env /usr/local/cargo/bin/anki-sync-server /
CMD ["/anki-sync-server"]