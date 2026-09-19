# Prism llama.cpp ROCm runtime

A minimal OCI image that packages a pinned PrismML `llama.cpp` ROCm release for Kubernetes inference workloads.

The image does not contain model weights. Mount GGUF files into the container and run `llama-server` normally.

## Image

```text
ghcr.io/twistedgrim/prism-llama-rocm:prism-b10709-9a9394a-rocmblas2
```

The image is published publicly. Pin deployments to an image digest after the first successful build rather than using `latest`.

## Contents

- Base image: `rocm/dev-ubuntu-24.04:7.2`
- PrismML release: [`prism-b10709-9a9394a`](https://github.com/PrismML-Eng/llama.cpp/releases/tag/prism-b10709-9a9394a)
- Runtime archive: `llama-prism-b10709-9a9394a-bin-ubuntu-rocm-7.2-x64.tar.gz`
- Archive SHA-256: `230f879d538bb9f794d25c908bc8c0f676774c41c3e70ea719131c86d899841d`

The Docker build verifies the archive checksum before extraction.

## Example

```bash
docker run --rm \
  --device /dev/kfd \
  --device /dev/dri \
  -v /path/to/models:/models:ro \
  -p 8080:8080 \
  ghcr.io/twistedgrim/prism-llama-rocm:prism-b10709-9a9394a-rocmblas2 \
  --model /models/Ternary-Bonsai-2-27B-PTQ1_0.gguf \
  --host 0.0.0.0 \
  --port 8080 \
  --n-gpu-layers 99 \
  --flash-attn on \
  --ctx-size 4096
```

## Scope

This image is intended for Prism-only GGUF formats that require PrismML's llama.cpp fork, including Ternary-Bonsai-2. It is not a substitute for upstream llama.cpp images.

The first target is an RX 9060 XT ROCm canary. Prism publishes the ROCm runtime but has not established a compatibility/performance claim for Ternary-Bonsai-2 on RDNA4; validate output coherence and VRAM behavior before production use.
