## ADDED Requirements

### Requirement: TypeScript LSP available
The image SHALL include `typescript-language-server` installed globally and available on PATH for the `dev` user.

#### Scenario: typescript-language-server is on PATH
- **WHEN** `typescript-language-server --version` is run as the `dev` user
- **THEN** it prints a version string without error

### Requirement: Python LSP available
The image SHALL include `pyright` installed globally and available on PATH for the `dev` user.

#### Scenario: pyright is on PATH
- **WHEN** `pyright --version` is run as the `dev` user
- **THEN** it prints a version string without error

### Requirement: Rust LSP available
The image SHALL include `rust-analyzer` installed and available on PATH for the `dev` user.

#### Scenario: rust-analyzer is on PATH
- **WHEN** `rust-analyzer --version` is run as the `dev` user
- **THEN** it prints a version string without error

### Requirement: Java LSP available
The image SHALL include `eclipse.jdt.ls` installed and a `jdtls` wrapper script available on PATH for the `dev` user.

#### Scenario: jdtls wrapper is on PATH
- **WHEN** `jdtls --version` is run as the `dev` user
- **THEN** it exits without a "command not found" error
