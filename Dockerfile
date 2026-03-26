FROM rust:1.85-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  clang \
  pkg-config \
  protobuf-compiler \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN rustup target add wasm32-unknown-unknown

COPY Cargo.toml Cargo.lock build.rs buf.gen.yaml rust-toolchain.toml ./
COPY abi ./abi
COPY proto ./proto
COPY src ./src
COPY substreams*.yaml ./

RUN cargo build --release --target wasm32-unknown-unknown

FROM golang:1.24-bookworm AS sink-builder

ARG SUBSTREAMS_SINK_SQL_VERSION=latest

RUN GOBIN=/usr/local/bin go install github.com/streamingfast/substreams-sink-sql/cmd/substreams-sink-sql@${SUBSTREAMS_SINK_SQL_VERSION}

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  ca-certificates \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=sink-builder /usr/local/bin/substreams-sink-sql /usr/local/bin/substreams-sink-sql
COPY --from=builder /app/target/wasm32-unknown-unknown/release/substreams.wasm /app/target/wasm32-unknown-unknown/release/substreams.wasm
COPY schema.sql ./
COPY sql ./sql
COPY scripts ./scripts
COPY substreams*.yaml ./

RUN chmod +x ./scripts/*.sh

ENV TOKENLAYER_ACTION=live
ENV TOKENLAYER_AUTO_SETUP=1

CMD ["./scripts/railway-run-chain.sh"]
