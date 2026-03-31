FROM rust:1-bookworm@sha256:fdb91abf3cb33f1ebc84a76461d2472fd8cf606df69c181050fa7474bade2895 AS build
WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates build-essential pkg-config libssl-dev \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ellenhp/auditlm.git .

# Build from the crate/workspace directory (not necessarily repo root)
WORKDIR /src/auditlm
RUN cargo build --release --locked

FROM debian:bookworm-slim@sha256:f06537653ac770703bc45b4b113475bd402f451e85223f0f2837acbf89ab020a
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# If the package builds a binary named "auditlm", it will be here:
COPY --from=build /src/auditlm/target/release/auditlm /usr/local/bin/auditlm
ENTRYPOINT ["/usr/local/bin/auditlm"]
