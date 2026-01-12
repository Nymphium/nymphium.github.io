# syntax=docker/dockerfile:1

FROM debian:stable-slim AS builder

RUN apt-get update && apt-get install -y git curl
RUN curl -fsSL https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm \
  --extra-conf \
  "cores = 0" \
  "filter-syscalls = false" # Apple Siliconにて必要

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

WORKDIR /app

RUN --mount=type=bind,source=.,rw \
  nix -L build '.#image' --show-trace -o /image.tar.zst

FROM scratch AS out
COPY --from=builder /image.tar.zst /
