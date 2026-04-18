## Requirements

### Requirement: Base image and user
The image SHALL be based on Ubuntu 24.04 LTS. It SHALL create a non-root user named `dev` with UID 1000 and passwordless sudo access. The default shell for `dev` SHALL be zsh. The container SHALL drop into a shell as the `dev` user by default.

#### Scenario: Container starts as dev user
- **WHEN** the container starts
- **THEN** the active user is `dev` (not root)

#### Scenario: Dev user can sudo
- **WHEN** `dev` runs a command with `sudo`
- **THEN** the command executes without a password prompt

### Requirement: Shell environment
The image SHALL include zsh, tmux, oh-my-zsh, and the Powerlevel10k theme. Standard oh-my-zsh plugins (git, zsh-autosuggestions, zsh-syntax-highlighting) SHALL be pre-installed. The default zsh theme SHALL be Powerlevel10k. A tmux configuration file SHALL be pre-installed at `/home/dev/.tmux.conf` with mouse mode enabled.

#### Scenario: Zsh is the login shell
- **WHEN** a user connects to the container
- **THEN** zsh starts automatically with oh-my-zsh and Powerlevel10k loaded

#### Scenario: tmux mouse mode enabled by default
- **WHEN** the `dev` user starts a new tmux session
- **THEN** mouse mode is active without any manual configuration

### Requirement: Version control tools
The image SHALL include git and the GitHub CLI (`gh`).

#### Scenario: Git is available
- **WHEN** `git --version` is run inside the container
- **THEN** it prints a version string without error

#### Scenario: GitHub CLI is available
- **WHEN** `gh --version` is run inside the container
- **THEN** it prints a version string without error

### Requirement: Node.js ecosystem
The image SHALL include Node.js (LTS), npm, and the Angular CLI (`ng`) installed globally via npm.

#### Scenario: Node and npm available
- **WHEN** `node --version` and `npm --version` are run
- **THEN** both print version strings

#### Scenario: Angular CLI available
- **WHEN** `ng version` is run
- **THEN** it prints the Angular CLI version

### Requirement: Python ecosystem
The image SHALL include Python 3 managed via pyenv, with pip available.

#### Scenario: Python available via pyenv
- **WHEN** `python3 --version` is run
- **THEN** it prints a version string managed by pyenv

### Requirement: Java ecosystem
The image SHALL include a Java JDK (Temurin), Maven, and Gradle, all managed via SDKMAN.

#### Scenario: Java, Maven, Gradle available
- **WHEN** `java --version`, `mvn --version`, and `gradle --version` are run
- **THEN** all print version strings without error

### Requirement: Rust ecosystem
The image SHALL include the Rust toolchain managed via `rustup`, providing `rustc`, `cargo`, `rustfmt`, and `clippy` from the stable channel. The `~/.cargo/bin` directory SHALL be on the `dev` user's PATH. The image SHALL also include `cargo-watch` and `cargo-edit` pre-installed.

#### Scenario: Rust toolchain available
- **WHEN** `rustc --version` and `cargo --version` are run
- **THEN** both print version strings without error

#### Scenario: Cargo bin on PATH
- **WHEN** a new zsh shell is opened as the `dev` user
- **THEN** `cargo` and `rustc` are found on PATH without additional configuration

### Requirement: Docker-in-Docker
The image SHALL include the Docker CLI and daemon binaries, allowing Docker to be run inside the container when launched in privileged mode.

#### Scenario: Docker available inside container
- **WHEN** the container runs privileged and `docker info` is run after starting dockerd
- **THEN** it returns Docker daemon info without error

### Requirement: Cloud and infrastructure CLIs
The image SHALL include: Azure CLI (`az`), kubectl, and Terraform.

#### Scenario: Cloud CLIs available
- **WHEN** `az --version`, `kubectl version --client`, and `terraform --version` are run
- **THEN** all print version strings without error

### Requirement: Claude Code
The image SHALL include the Claude Code CLI (`claude`) installed and available on the PATH for the `dev` user.

#### Scenario: Claude Code available
- **WHEN** `claude --version` is run as the `dev` user
- **THEN** it prints a version string without error

### Requirement: OpenSpec CLI
The image SHALL include the `openspec` CLI installed and available on the PATH for the `dev` user.

#### Scenario: OpenSpec CLI available
- **WHEN** `openspec --version` is run as the `dev` user
- **THEN** it prints a version string without error

### Requirement: LSP servers
The image SHALL include LSP servers for TypeScript (`typescript-language-server`), Python (`pyright`), Rust (`rust-analyzer`), and Java (`eclipse.jdt.ls` via a `jdtls` wrapper), all available on PATH for the `dev` user.

#### Scenario: All LSP servers available
- **WHEN** `typescript-language-server --version`, `pyright --version`, `rust-analyzer --version`, and `jdtls` are run as the `dev` user
- **THEN** each command exits without a "command not found" error
