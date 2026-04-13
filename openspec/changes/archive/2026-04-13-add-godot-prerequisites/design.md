## Context

The dev container runs Ubuntu 24.04 on aarch64 (Apple Silicon via OrbStack). The primary workflow for Godot development is: the container agent generates and edits game files and runs headless tests; the developer opens the same project in the Godot editor on the macOS host for manual testing and visual iteration. Files are shared via the existing `${WORKSPACE_PATH}` volume mount — no export pipeline or display forwarding is needed.

The container already has Python (via pyenv), Java/Maven, Rust, and Node.js toolchains established. This change follows the same layered pattern: system-level installs under root, user-level tools under the `dev` user.

## Goals / Non-Goals

**Goals:**
- Run `godot --headless` for asset import, C# solution builds, and gdUnit4 scene tests
- Compile and test C# Godot projects with `dotnet test` inside the container
- Lint and format GDScript files with `gdtoolkit`
- Provide a C# LSP server for Claude Code editor integration

**Non-Goals:**
- Running the Godot editor GUI inside the container (host handles this)
- Exporting game binaries from the container (host editor handles this)
- Configuring per-project files (gdUnit4Net NuGet package, `.runsettings`, Godot plugin)
- Supporting platforms other than Linux arm64 in-container

## Decisions

### 1. Godot .NET build, not the standard build

The standard Godot binary has no C# scripting host. Only the `.NET` (mono) variant can compile and run C# scripts. Since C# is the primary scripting language, the `.NET` build is mandatory.

**Alternatives considered**: Shipping both binaries — rejected as unnecessary complexity. The `.NET` build is a strict superset; it runs GDScript equally well.

### 2. .NET SDK 10.0 (latest LTS) over minimum .NET 8

Godot 4.6 requires minimum .NET 8 but supports targeting newer versions. Per the user's stated preference for latest stable/LTS, .NET 10.0 (LTS, released Nov 2025) is the right choice. It will be supported through Nov 2028.

**Installation method**: Microsoft's official apt feed (`packages.microsoft.com`), consistent with how other tools in this Dockerfile use vendor-provided apt sources.

### 3. Godot binary installed system-wide at `/usr/local/bin/godot`

Installing as root to `/usr/local/bin/godot` makes the binary available to all users and to tools like gdUnit4Net that look for it via `GODOT_BIN`. The `GODOT_BIN` env var is set in the Dockerfile so every project picks it up without per-project `.runsettings` configuration.

**Alternatives considered**: User-local install under `~/.local/bin` — rejected because system-level placement is consistent with how other binaries (kubectl, terraform, etc.) are installed in this Dockerfile.

### 4. `csharp-ls` over OmniSharp

`csharp-ls` is a lightweight, actively maintained Roslyn-based LSP server installable as a `dotnet tool`. OmniSharp requires a separate download, has heavier runtime requirements, and its successor (the C# Dev Kit) is VS Code-specific. `csharp-ls` fits the container's minimal footprint philosophy.

### 5. `gdtoolkit` via pyenv pip

The container manages Python via pyenv (`python 3.12`). Installing `gdtoolkit` via `pip install gdtoolkit` (using the pyenv-managed pip) is consistent with the existing Python setup and avoids system pip conflicts.

## Risks / Trade-offs

- **Godot version pinning**: The binary URL is pinned to 4.6.2. When a new Godot release ships, the Dockerfile must be updated manually. → Mitigation: the URL pattern is stable and straightforward to update; document the version in a comment.
- **ARM64 only**: The binary is the Linux arm64 build. If this container is ever run on x86_64, the binary won't execute. → Mitigation: the existing rust-analyzer step already has arch-detection logic; a future improvement could add the same pattern here. For now, aarch64 is the only target.
- **.NET SDK apt feed**: Microsoft's apt feed is a third-party source. If the feed URL changes, the build breaks. → Mitigation: this is the official, documented installation method for .NET on Ubuntu; same risk class as Docker CE and GitHub CLI feeds already in the Dockerfile.
- **gdUnit4Net headless test startup time**: Scene tests that require the Godot runtime have non-trivial startup overhead (~2–5s per run). → Accepted trade-off; pure C# logic tests run without the engine and are fast.
