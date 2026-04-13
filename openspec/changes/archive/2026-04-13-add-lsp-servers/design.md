## Context

The dev container Dockerfile installs tools in language-grouped `RUN` blocks. Global npm packages go in a single `npm install -g` line. Rust tooling is installed via `rustup` and `cargo install`. Java tooling is managed via SDKMAN. The container targets `x86_64` Linux (Ubuntu 24.04).

## Goals / Non-Goals

**Goals:**
- All four LSP servers available on PATH for the `dev` user after container start, with no additional setup

**Non-Goals:**
- Editor/plugin configuration (e.g., Neovim lspconfig, VS Code settings) — that's user responsibility
- Pinning to specific LSP server versions
- LSP servers for languages not already in the container (e.g., Go, C++)

## Decisions

### typescript-language-server and pyright: add to existing `npm install -g` line

Both are npm packages. The Dockerfile already has:
```
RUN npm install -g @angular/cli @anthropic-ai/claude-code
```
Adding `typescript-language-server` and `pyright` here keeps global npm installs in one layer.

**Note**: `typescript-language-server` requires `typescript` as a peer dependency — add both.

### rust-analyzer: download binary from GitHub releases

`rust-analyzer` is not on npm and is not a cargo crate intended for `cargo install`. The canonical distribution is a pre-built binary from the GitHub releases page (`rust-lang/rust-analyzer`). Download, decompress, and place in `/usr/local/bin`.

**Alternatives considered:**
- `rustup component add rust-analyzer`: Available but couples the analyzer version to the toolchain; the standalone binary is more up-to-date and editor-agnostic. Rejected for now, but a reasonable alternative.

### eclipse.jdt.ls: download milestone build, install to `/opt/jdtls`

`eclipse.jdt.ls` is distributed as a tarball from the Eclipse download mirror or GitHub releases (`eclipse-jdtls/eclipse.jdt.ls`). Install to `/opt/jdtls` and provide a wrapper script at `/usr/local/bin/jdtls` so editors can find it on PATH.

The wrapper must pass the correct `--jvm-arg` for the data directory, which is workspace-specific — editors typically handle this, but the wrapper sets a sensible default.

**Alternatives considered:**
- Install via `npm install -g @alan.hamlett/eclipse-jdt-ls` (unofficial npm wrapper): less reliable, not official. Rejected.
- Mason.nvim / VS Code extension managed install: user-space only, not container-global. Rejected.

## Risks / Trade-offs

- **rust-analyzer binary architecture**: Must download the `x86_64-unknown-linux-gnu` build. If the container ever targets ARM, this step needs updating. → Document the architecture assumption.
- **jdtls requires Java**: `eclipse.jdt.ls` needs a JDK at runtime — Java is already in the container via SDKMAN/Temurin, but the `JAVA_HOME` env var must be set in the wrapper script.
- **Image size**: Four LSP servers add meaningful layer size (jdtls especially, ~100MB). → Acceptable for a dev tooling image.

## Migration Plan

Rebuild the container image. No data migration required — purely additive.
