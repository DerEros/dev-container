## Context

The Dockerfile builds a developer container image used on Apple Silicon (arm64) and potentially on x86_64 Linux or Windows (WSL2). Several binary download steps embed hardcoded architecture strings, with Godot being the most critical failure point. The rust-analyzer step already performs its own inline `uname -m` detection but uses a duplicated pattern that doesn't benefit from a shared source.

Docker BuildKit provides a built-in `TARGETARCH` build ARG that resolves to the native build architecture when no `--platform` flag is given, and to the requested architecture when cross-compiling. This is the natural foundation for centralized arch detection.

## Goals / Non-Goals

**Goals:**
- Single source of truth for architecture detection at the top of the Dockerfile
- Correct builds on arm64 (Apple Silicon) and amd64 (x86_64) without any flag changes for native builds
- Extensible pattern: adding a new arch-sensitive tool requires only adding a variable to the central mapping block
- Cross-compile support via `docker build --platform linux/amd64` with no Dockerfile changes

**Non-Goals:**
- Support for 32-bit ARM (`armv7`) or other architectures beyond arm64/amd64
- Changing jdtls config directory detection (works today, left unchanged)
- Parameterizing OS-level choices (Ubuntu version, .NET version, etc.)

## Decisions

### Decision: Docker `TARGETARCH` over `uname -m`

**Chosen**: `ARG TARGETARCH` populated by Docker BuildKit.

**Alternatives considered**:
- `uname -m` at RUN time: reflects the build host, not the intended target. Breaks cross-compilation. Already used by rust-analyzer — this change replaces that usage.
- `dpkg --print-architecture`: Debian/Ubuntu convention, already used for apt repos. Correct values but only available after base packages are installed; `TARGETARCH` is available from the first layer.

**Rationale**: `TARGETARCH` is set before any `RUN` step, is cross-compile-aware, and uses OCI conventions (`amd64`/`arm64`) that are well-understood.

### Decision: `/etc/arch.sh` mapping file over inline case statements per tool

**Chosen**: An early `RUN` block writes derived arch variables to `/etc/arch.sh`; each tool step sources it with `. /etc/arch.sh`.

**Alternatives considered**:
- Inline `case "${TARGETARCH}"` per tool RUN: no shared file needed, but duplicates mapping logic if more tools are added.
- Docker `ENV` set from `ARG`: `ENV` cannot be set conditionally in a single statement; requires separate `RUN` per variable, which is awkward for multiple derived values.

**Rationale**: One mapping block, one place to update. The `. /etc/arch.sh` prefix is minimal overhead per tool step.

### Decision: Variables to derive

| Variable | arm64 | amd64 |
|---|---|---|
| `GODOT_ARCH` | `linux_arm64` | `linux_x86_64` |
| `GODOT_BIN` | `arm64` | `x86_64` |
| `RA_TARGET` | `aarch64-unknown-linux-gnu` | `x86_64-unknown-linux-gnu` |

Only tools with actual multi-value naming schemes get entries. APT-based tools (`docker-ce`, `gh`, `kubectl`, `terraform`) already handle arch via `dpkg --print-architecture` in their repo setup and need no changes.

## Risks / Trade-offs

- **Risk**: `/etc/arch.sh` is sourced with `.` (dot-source) in each RUN — if the file is missing, the step silently proceeds with unset variables and will produce a confusing download failure. → **Mitigation**: The arch-detection block is an early layer; a missing file would be caught on the very first tool step that uses it.
- **Risk**: Future Godot releases may change the zip naming convention. → **Mitigation**: Variables are centralized, so only the mapping block needs updating, not multiple scattered strings.
- **Trade-off**: Every arch-sensitive RUN step gains a `. /etc/arch.sh &&` prefix, adding minor visual noise. Accepted in exchange for a single source of truth.

## Migration Plan

1. Add `ARG TARGETARCH` after the existing `ENV` declarations at the top of the Dockerfile
2. Add the arch-detection `RUN` block immediately after, writing `/etc/arch.sh`
3. Update the Godot install step to source `/etc/arch.sh` and use `${GODOT_ARCH}` / `${GODOT_BIN}`
4. Update the rust-analyzer install step to source `/etc/arch.sh` and use `${RA_TARGET}` (removing the inline `uname -m` detection)
5. Rebuild the image on arm64 to verify no regression; rebuild on amd64 (or via `--platform linux/amd64`) to verify the new paths resolve correctly

No rollback complexity — the change is contained to the Dockerfile and produces identical output on arm64 to the previous version.

## Open Questions

- None. jdtls config directory detection is intentionally left unchanged per project decision.
