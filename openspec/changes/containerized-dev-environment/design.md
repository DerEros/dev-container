## Context

Agentic Claude Code sessions need a contained, reproducible environment. The previous incarnation was hand-built interactively with no Dockerfile or compose file — no version control, no reproducibility. This design formalises the environment as a proper project: a Dockerfile, a compose file, and a launcher script, all committed to version control.

The environment runs on Docker Desktop for macOS. The container is Ubuntu 24.04. The user inside the container is non-root (`dev`) because Claude Code refuses to run as root. Files in the mounted workspace are created by `dev` (UID 1000); Docker Desktop's VirtioFS handles the macOS ↔ Linux UID boundary transparently for IDE access.

## Goals / Non-Goals

**Goals:**
- Single command (`spin.sh <name>`) to create or reattach to a named dev container
- All tools pre-installed and version-pinned in the image
- Full filesystem isolation — container cannot touch anything on the host outside the two mounted directories
- Per-project Claude config and auth persists across container recreates
- Project workspace accessible from macOS IDEs simultaneously
- True Docker-in-Docker (no host socket mount)

**Non-Goals:**
- Multi-user or CI/CD use
- Automatic Claude Code startup (user starts it manually)
- Network isolation (container has normal outbound internet access)
- Windows or Linux host support (macOS only for now)

## Decisions

**D1: Non-root `dev` user with passwordless sudo**
Claude Code refuses to run as root. A `dev` user with sudo covers both the Claude requirement and normal developer needs (installing packages, running dockerd). Alternative: rootless Docker — rejected for complexity.

**D2: Privileged mode for Docker-in-Docker**
True DinD (no host socket) requires either `--privileged` or the Sysbox runtime. Sysbox requires a kernel module install on the host. `--privileged` works out of the box with Docker Desktop. Blast-radius concern (privileged containers can affect the host kernel) is accepted: the primary threat model is filesystem accidents, not kernel exploits.

**D3: Two volume mounts, nothing else**
- `~/workspace/<name>/` → `/home/dev/workspace/` — project files
- `~/.dev-containers/<name>/.claude/` → `/home/dev/.claude/` — Claude config, auth, skills, custom commands

Everything else (tools, OS, shell config) is baked into the image. Host directories are created by `spin.sh` on first use. No other host paths are mounted.

**D4: Reattach-or-create semantics in `spin.sh`**
If a container named `dev-<name>` exists (running or stopped), start it and exec in. If not, create it via `docker compose`. This means data in the two mounted volumes persists across stops and recreates (when the image is updated, destroy and recreate — data survives because it lives on the host).

**D5: Tools installed via package managers inside the image**
- sdkman: Java (Temurin), Maven, Gradle
- pyenv: Python
- apt / official install scripts: Node.js, npm, gh, docker-ce, azure-cli, kubectl, terraform, zsh, tmux
- npm global: Angular CLI (`@angular/cli`)
- Direct binary: Claude Code

Pinning strategy: use latest stable at image build time; rebuild image to update. No auto-update inside container.

**D6: `spin.sh` lives in the repo, added to host PATH**
The script references the compose file relative to its own location. User installs by symlinking or adding the repo to `$PATH`. Alternative: install to `/usr/local/bin` — rejected, prefer keeping the install self-contained in the repo.

## Risks / Trade-offs

- **Privileged DinD** → Accepted risk. Mitigation: document clearly, don't expose container ports unnecessarily.
- **UID mismatch (1000 vs macOS 501)** → Docker Desktop VirtioFS handles this in practice. Mitigation: document workaround (rebuild with `--build-arg UID=$(id -u)`) if it becomes a problem.
- **Large image size** → All tools baked in means a multi-GB image. Mitigation: layer ordering to maximise cache; accept the size as the cost of "everything just works".
- **Tool version drift** → Versions baked at build time go stale. Mitigation: rebuild image periodically; track versions in Dockerfile comments.
- **`spin.sh` path assumption** → Script assumes compose file is sibling. Mitigation: use `$(dirname "$0")` to resolve path relative to script location.
