## Context

The dev container is built from a single `Dockerfile` targeting Ubuntu 24.04 LTS. Language ecosystems are installed at image build time: Node.js via nvm, Python via pyenv, and JVM tools via SDKMAN. Each manager owns its toolchain versions and exposes binaries on the `dev` user's PATH via shell initialization files.

Rust uses `rustup` as its canonical toolchain manager — the Rust equivalent of nvm/pyenv/SDKMAN. Installing rustup at build time and pre-fetching the stable toolchain avoids runtime downloads and mirrors the pattern used by other ecosystems in the image.

## Goals / Non-Goals

**Goals:**
- Install `rustup` and the stable Rust toolchain (`rustc`, `cargo`, `rustfmt`, `clippy`) at image build time
- Ensure `~/.cargo/bin` is on the `dev` user's PATH in zsh
- Install a small set of productivity Cargo tools: `cargo-watch`, `cargo-edit`

**Non-Goals:**
- Managing multiple Rust toolchain versions (stable only; users can `rustup install` others at runtime)
- Pre-installing project-specific dependencies or crates
- Configuring Rust analyzer or IDE extensions (editor tooling is user-managed)

## Decisions

### Decision: Use rustup (not system package manager)
Install Rust via `rustup` rather than `apt`. Rationale: rustup is the official toolchain manager, supports stable/nightly channel switching, and is how the Rust project intends Rust to be installed. The apt package is often outdated.

**Alternatives considered:**
- `apt install rustc cargo` — outdated versions, no toolchain management
- Pre-built Docker layer from `rust:latest` — would switch base image; inconsistent with our Ubuntu 24.04 base

### Decision: Run rustup install as the `dev` user
rustup installs into `$HOME/.cargo` and `$HOME/.rustup`. Running the install step as `dev` (not root) ensures the toolchain is in the correct user home and avoids permission issues. This is consistent with pyenv and nvm which are also installed per-user.

### Decision: Install cargo-watch and cargo-edit as default tools
These two tools cover the most common Rust development workflows (auto-rebuild on change, and `cargo add`/`cargo rm` for dependency management). Additional tools are easy to install at runtime via `cargo install`.

**Alternatives considered:**
- Install no extra tools — leaner image but reduces out-of-the-box usability
- Install `cargo-nextest`, `cargo-tarpaulin` — useful but heavier; can be added per-project

## Risks / Trade-offs

- **Image size increase (~1–2 GB)** → Mitigation: Accept; consistent with other toolchain layers (SDKMAN/JDK is similarly large). Stable toolchain only — no nightly bloat.
- **rustup self-update at runtime** → Mitigation: Document that rustup/cargo are pinned to build-time versions; users can run `rustup update` inside the container.
- **Cargo build cache not persisted** → Mitigation: Users who need persistent build caches should mount a volume at `~/.cargo/registry` — outside this change's scope.
