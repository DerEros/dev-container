## Why

The dev container supports multiple languages (TypeScript, Python, Rust, Java) but ships no LSP servers, so editor features like go-to-definition, hover docs, and diagnostics require manual post-start setup. Pre-installing LSP servers makes the container immediately usable with any LSP-capable editor or plugin (Neovim, VS Code remote, Helix, etc.).

## What Changes

- `typescript-language-server` installed globally via npm (TypeScript/JavaScript LSP)
- `pyright` installed globally via npm (Python LSP)
- `rust-analyzer` binary installed for the `dev` user (Rust LSP)
- `eclipse.jdt.ls` installed for the `dev` user (Java LSP)

## Capabilities

### New Capabilities

- `lsp-servers`: LSP servers for TypeScript, Python, Rust, and Java pre-installed and available on PATH

### Modified Capabilities

- `dev-container-image`: Adds LSP server binaries as pre-installed tools

## Impact

- `Dockerfile`: New install steps for each LSP server
- `openspec/specs/dev-container-image/spec.md`: New requirements for LSP server availability
