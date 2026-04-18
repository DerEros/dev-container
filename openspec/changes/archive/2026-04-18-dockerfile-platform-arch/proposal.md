## Why

The Dockerfile contains platform-specific binary downloads hardcoded to `arm64`, making it fail silently or explicitly on `amd64` (x86_64) hosts. As the project is used by colleagues on x86_64 Linux and potentially Windows (WSL2), the image must build correctly on any supported platform without requiring manual edits.

## What Changes

- Add a single `ARG TARGETARCH` declaration at the top of the Dockerfile, populated automatically by Docker BuildKit from the build host's architecture (or from `--platform` when cross-compiling)
- Add an early `RUN` block that maps `TARGETARCH` to tool-specific arch strings and writes them to `/etc/arch.sh`
- Update the Godot install step to source `/etc/arch.sh` and use the derived variables instead of hardcoded `arm64` strings
- Update the rust-analyzer install step to source `/etc/arch.sh` instead of re-running its own inline `uname -m` detection

## Capabilities

### New Capabilities

- `dockerfile-platform-arch`: Central architecture detection block in Dockerfile that derives per-tool arch strings from Docker's native `TARGETARCH` build arg, enabling correct multi-platform image builds without explicit `--platform` flags for native builds

### Modified Capabilities

<!-- No existing spec-level behavior changes -->

## Impact

- `Dockerfile`: ARG declaration, new arch-detection RUN block, modified Godot and rust-analyzer install steps
- No changes to `docker-compose.yml`, `spin.sh`, or config files
- Builders on arm64 (Apple Silicon) continue to work as before; builders on amd64 now also produce a working image
