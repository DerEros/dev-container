## ADDED Requirements

### Requirement: Architecture detection block
The Dockerfile SHALL declare `ARG TARGETARCH` to receive the target architecture from Docker BuildKit, and SHALL derive tool-specific architecture strings from it in a single early RUN block that writes `/etc/arch.sh`.

#### Scenario: Native arm64 build
- **WHEN** `docker build .` is run on an arm64 host (Apple Silicon)
- **THEN** `TARGETARCH` resolves to `arm64` and `/etc/arch.sh` contains `GODOT_ARCH=linux_arm64`, `GODOT_BIN=arm64`, `RA_TARGET=aarch64-unknown-linux-gnu`

#### Scenario: Native amd64 build
- **WHEN** `docker build .` is run on an amd64 (x86_64) host
- **THEN** `TARGETARCH` resolves to `amd64` and `/etc/arch.sh` contains `GODOT_ARCH=linux_x86_64`, `GODOT_BIN=x86_64`, `RA_TARGET=x86_64-unknown-linux-gnu`

#### Scenario: Explicit cross-compile
- **WHEN** `docker build --platform linux/amd64 .` is run on an arm64 host
- **THEN** `TARGETARCH` resolves to `amd64` and the resulting image contains amd64 binaries for Godot and rust-analyzer

#### Scenario: Unsupported architecture
- **WHEN** `docker build .` is run on a host with an architecture other than arm64 or amd64
- **THEN** the build SHALL fail with a clear error message identifying the unsupported architecture

### Requirement: Godot platform-aware install
The Godot install step SHALL use the arch variables from `/etc/arch.sh` to construct the correct download URL, zip path, and binary name for the target architecture.

#### Scenario: Godot installs on arm64
- **WHEN** the image is built for arm64
- **THEN** the Godot zip downloaded is `Godot_v4.6.2-stable_mono_linux_arm64.zip` and the installed binary is `Godot_v4.6.2-stable_mono_linux.arm64`

#### Scenario: Godot installs on amd64
- **WHEN** the image is built for amd64
- **THEN** the Godot zip downloaded is `Godot_v4.6.2-stable_mono_linux_x86_64.zip` and the installed binary is `Godot_v4.6.2-stable_mono_linux.x86_64`

### Requirement: rust-analyzer platform-aware install
The rust-analyzer install step SHALL source `/etc/arch.sh` and use `${RA_TARGET}` to construct the download URL, replacing the previous inline `uname -m` detection.

#### Scenario: rust-analyzer installs on arm64
- **WHEN** the image is built for arm64
- **THEN** the downloaded binary is `rust-analyzer-aarch64-unknown-linux-gnu.gz`

#### Scenario: rust-analyzer installs on amd64
- **WHEN** the image is built for amd64
- **THEN** the downloaded binary is `rust-analyzer-x86_64-unknown-linux-gnu.gz`
