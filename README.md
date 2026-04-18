# dev-container

A Docker-based development environment with all major language toolchains, cloud/infra CLIs, and Claude Code pre-installed. Spin up an isolated workspace for any project with a single command — no host pollution, consistent environment across machines.

Each project gets its own workspace directory and Claude Code configuration, so your chat history, memory, and settings stay neatly separated per project.

## Included tools

**Language runtimes**
- Node.js LTS
- Python 3.12 via [pyenv](https://github.com/pyenv/pyenv) (version-switchable)
- Java 21 LTS (Temurin) via [SDKMAN](https://sdkman.io/) — Maven and Gradle included
- Rust via [rustup](https://rustup.rs/) — `cargo-watch` and `cargo-edit` included
- .NET SDK 10.0

**Game development**
- Godot 4.6.2 (.NET/mono build, headless) — see [Prerequisites](#prerequisites) for architecture note

**Cloud & infrastructure CLIs**
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) (v1.31)
- [Terraform](https://www.terraform.io/)
- [GitHub CLI](https://cli.github.com/)

**Containers**
- Docker CE (Docker-in-Docker) — see [Prerequisites](#prerequisites) for platform note

**AI**
- [Claude Code](https://claude.ai/code) — installed as user, auto-update enabled

**Shell & terminal**
- zsh + [oh-my-zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (pre-configured, no setup wizard)
- [tmux](https://github.com/tmux/tmux) with [Catppuccin Mocha](https://github.com/catppuccin/tmux) theme
- zsh-autosuggestions, zsh-syntax-highlighting

**LSP servers** (for editor integrations)
- TypeScript (`typescript-language-server`)
- Python (`pyright`)
- Rust (`rust-analyzer`)
- Java (`eclipse.jdt.ls`)
- C# (`csharp-ls`)

**Frontend**
- Angular CLI

**GDScript**
- [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) (linter & formatter)

## Prerequisites

Docker with the Compose plugin (any recent Docker installation includes this).

> [!WARNING]
> **arm64 only for Godot** — The Godot binary bundled in this image is built for `arm64` (Linux). If you are on an `x86_64` machine, you will need to swap the download URL in the Dockerfile (step 11) for the `linux_x86_64` variant from the [Godot releases page](https://github.com/godotengine/godot/releases).

> [!NOTE]
> **Docker-in-Docker: tested on OrbStack / macOS** — The Docker daemon inside the container uses the `vfs` storage driver, which works reliably on OrbStack and macOS. On Linux hosts or Docker Desktop, this should also work, but may require adjustments to the storage driver configuration.

## Getting started

**1. Clone the repository**

```bash
git clone https://github.com/DerEros/dev-container.git
cd dev-container
```

**2. Build the image**

```bash
docker build -t dev-container .
```

This takes a few minutes on first build — all toolchains are installed at build time so container startup is instant.

**3. Spin up a project shell**

```bash
./spin.sh <project-name>
```

Replace `<project-name>` with whatever you are working on (e.g., `my-app`, `infra`). You will land in a `zsh` shell inside the container with your project workspace ready.

### How spin.sh works

`spin.sh` manages the full lifecycle of a project container:

```
./spin.sh <project-name>
         │
         ├── container running? ──────► attach a new shell
         ├── container stopped? ──────► start it, then attach
         └── container doesn't exist? ► create via docker compose, then attach
```

**Project isolation:** each project name gets its own:
- Workspace: `~/workspace/<project-name>/` on the host → `/home/dev/workspace` in the container
- Claude config: `~/.dev-containers/<project-name>/.claude/` on the host → `/home/dev/.claude` in the container

This means Claude Code chat history, memory, and settings are fully isolated between projects.

## Customization

The most common customization is adjusting the shell environment to match your preferences.

**Replace the Powerlevel10k config**

The container ships with a pre-configured `config/p10k.zsh` that suppresses the setup wizard. To use your own:

1. Replace `config/p10k.zsh` in the repository with your own `.p10k.zsh`
2. Rebuild the image: `docker build -t dev-container .`

**Add aliases, exports, or functions**

Edit the zshrc setup steps in the Dockerfile (look for the `echo '...' >> "${HOME}/.zshrc"` lines) to append your own shell configuration, then rebuild.

Alternatively, mount a dotfiles directory by adding a volume to `docker-compose.yml` and sourcing it from `.zshrc`:

```yaml
volumes:
  - ${WORKSPACE_PATH}:/home/dev/workspace
  - ${CLAUDE_CONFIG_PATH}:/home/dev/.claude
  - /path/to/your/dotfiles:/home/dev/dotfiles  # add this
```
