FROM rocm/dev-ubuntu-24.04:7.2

ARG PRISM_RELEASE=prism-b10709-9a9394a
ARG PRISM_ARCHIVE_SHA256=230f879d538bb9f794d25c908bc8c0f676774c41c3e70ea719131c86d899841d

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Keep the large ROCm dependencies in independent layers so registries and nodes
# can retry/cache them separately.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y hipblaslt \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y rocsolver \
    && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y hipblas \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig

RUN archive="llama-${PRISM_RELEASE}-bin-ubuntu-rocm-7.2-x64.tar.gz" \
    && curl --fail --location --silent --show-error \
        "https://github.com/PrismML-Eng/llama.cpp/releases/download/${PRISM_RELEASE}/${archive}" \
        --output /tmp/llama.tar.gz \
    && printf '%s  %s\n' "${PRISM_ARCHIVE_SHA256}" /tmp/llama.tar.gz > /tmp/llama.tar.gz.sha256 \
    && sha256sum --check --strict /tmp/llama.tar.gz.sha256 \
    && mkdir -p /opt/prism \
    && tar --extract --gzip --file /tmp/llama.tar.gz --directory /opt/prism --strip-components=1 \
    && rm /tmp/llama.tar.gz \
    && /opt/prism/llama-server --version \
    && ldd /opt/prism/libggml-hip.so > /tmp/libggml-hip.ldd \
    && ! grep --quiet 'not found' /tmp/libggml-hip.ldd \
    && rm /tmp/libggml-hip.ldd

ENV PATH="/opt/prism:${PATH}"

EXPOSE 8080
ENTRYPOINT ["/opt/prism/llama-server"]
