## Why

The dev container currently supports Node.js, Python, and JVM ecosystems but lacks Rust support. Adding the Rust toolchain (rustup, cargo, rustc) enables Rust development workflows within the container, consistent with how other language ecosystems are already managed.

## What Changes

- Install `rustup` as the Rust toolchain manager for the `dev` user
- Provide `cargo`, `rustc`, and `rustfmt` via the stable toolchain
- Include `clippy` for linting
- Add commonly used Cargo tools: `cargo-watch`, `cargo-edit`

## Capabilities

### New Capabilities

- `rust-toolchain`: Rust compiler, Cargo package manager, and associated developer tools available in the container image

### Modified Capabilities

- `dev-container-image`: Adds a Rust ecosystem requirement to the existing container image spec

## Impact

- `Dockerfile`: New installation steps for rustup and the stable toolchain
- PATH configuration: `~/.cargo/bin` must be on the `dev` user's PATH
- Image size will increase (~1–2 GB depending on toolchain components cached)
