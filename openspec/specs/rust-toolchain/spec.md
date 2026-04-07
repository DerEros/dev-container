## Requirements

### Requirement: Rust toolchain via rustup
The image SHALL install `rustup` as the Rust toolchain manager for the `dev` user. The stable Rust toolchain SHALL be pre-installed at image build time, providing `rustc`, `cargo`, `rustfmt`, and `clippy` without requiring a network download at runtime.

#### Scenario: rustc is available
- **WHEN** `rustc --version` is run inside the container
- **THEN** it prints a version string for the stable Rust compiler without error

#### Scenario: cargo is available
- **WHEN** `cargo --version` is run inside the container
- **THEN** it prints a version string without error

#### Scenario: rustfmt is available
- **WHEN** `rustfmt --version` is run inside the container
- **THEN** it prints a version string without error

#### Scenario: clippy is available
- **WHEN** `cargo clippy --version` is run inside the container
- **THEN** it prints a version string without error

#### Scenario: rustup is available
- **WHEN** `rustup --version` is run inside the container
- **THEN** it prints a version string without error

### Requirement: Cargo PATH configuration
The `~/.cargo/bin` directory SHALL be included in the `dev` user's PATH so that Cargo-installed binaries are accessible without manual PATH modification.

#### Scenario: Cargo binaries on PATH
- **WHEN** a new zsh shell is opened as the `dev` user
- **THEN** `cargo`, `rustc`, and other Cargo-installed tools are found on PATH without sourcing additional files

### Requirement: Cargo productivity tools
The image SHALL pre-install `cargo-watch` and `cargo-edit` via `cargo install` at image build time.

#### Scenario: cargo-watch is available
- **WHEN** `cargo watch --version` is run inside the container
- **THEN** it prints a version string without error

#### Scenario: cargo-edit is available
- **WHEN** `cargo add --help` is run inside the container
- **THEN** it prints help output without error
