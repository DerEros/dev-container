## 1. Add TARGETARCH and arch detection block

- [x] 1.1 Add `ARG TARGETARCH` declaration after the existing `ENV` lines at the top of the Dockerfile (after `ENV LANG=C.UTF-8`)
- [x] 1.2 Add early `RUN` block that maps `TARGETARCH` to tool-specific arch strings and writes them to `/etc/arch.sh`, with an `exit 1` case for unsupported architectures

## 2. Update Godot install step

- [x] 2.1 Prefix the Godot `RUN` block with `. /etc/arch.sh` and replace all hardcoded `arm64` / `linux_arm64` strings with `${GODOT_BIN}` and `${GODOT_ARCH}` variables

## 3. Update rust-analyzer install step

- [x] 3.1 Replace the inline `uname -m` + case statement in the rust-analyzer `RUN` block with `. /etc/arch.sh` and use `${RA_TARGET}` directly

## 4. Verify

- [x] 4.1 Build the image on the native platform (`docker build -t dev-container .`) and confirm no errors
- [x] 4.2 Confirm `godot --version` and `rust-analyzer --version` run successfully inside the container
