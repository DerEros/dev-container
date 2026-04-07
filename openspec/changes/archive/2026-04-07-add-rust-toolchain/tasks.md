## 1. Dockerfile: Install Rust Toolchain

- [x] 1.1 Add a `USER dev` build stage that runs `rustup-init` to install rustup and the stable toolchain non-interactively
- [x] 1.2 Ensure `~/.cargo/bin` is added to the `dev` user's PATH in `.zshrc` or the shell environment setup
- [x] 1.3 Install `cargo-watch` via `cargo install cargo-watch` during the image build
- [x] 1.4 Install `cargo-edit` via `cargo install cargo-edit` during the image build

## 2. Verification

- [x] 2.1 Build the Docker image locally and verify `rustc --version` prints the stable version
- [x] 2.2 Verify `cargo --version` is accessible without additional PATH configuration in a new zsh shell
- [x] 2.3 Verify `rustfmt --version` and `cargo clippy --version` both succeed
- [x] 2.4 Verify `rustup --version` succeeds
- [x] 2.5 Verify `cargo watch --version` succeeds
- [x] 2.6 Verify `cargo add --help` succeeds (cargo-edit)
