## ADDED Requirements

### Requirement: LSP servers
The image SHALL include LSP servers for TypeScript (`typescript-language-server`), Python (`pyright`), Rust (`rust-analyzer`), and Java (`eclipse.jdt.ls` via a `jdtls` wrapper), all available on PATH for the `dev` user.

#### Scenario: All LSP servers available
- **WHEN** `typescript-language-server --version`, `pyright --version`, `rust-analyzer --version`, and `jdtls` are run as the `dev` user
- **THEN** each command exits without a "command not found" error
