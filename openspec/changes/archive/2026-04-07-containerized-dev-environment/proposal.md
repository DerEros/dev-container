## Why

Agentic Claude Code development works best when the agent runs freely in an isolated environment — safe from accidentally modifying anything outside the project. Today there is no reproducible, version-controlled definition of this environment; it was hand-crafted in a chat session with no source of truth. This change establishes it as a proper project.

## What Changes

- **Dockerfile** defining the complete dev container image (Ubuntu 24.04, non-root `dev` user with sudo, all tools pre-installed and pinned)
- **docker-compose.yml** wiring up volumes and container settings
- **spin.sh** script: one command to create or reattach to a named container instance, with host directories auto-created
- All tools baked into the image: Node.js, Python, Java, Git, GitHub CLI, Docker-in-Docker (privileged), zsh + tmux + oh-my-zsh + Powerlevel10k, Claude Code, Maven, Gradle, Angular CLI, Azure CLI, kubectl, Terraform

## Capabilities

### New Capabilities
- `dev-container-image`: Docker image definition with all tools pre-installed for agentic development
- `spin-script`: Shell script to create or reattach to a named container instance with correct volume mounts
- `volume-layout`: Host directory conventions for workspace and per-project Claude config persistence

### Modified Capabilities

## Impact

- New files only — no existing code modified
- Requires Docker Desktop on macOS host
- Container runs privileged (needed for Docker-in-Docker)
- Per-project Claude config (`~/.dev-containers/<name>/.claude/`) persists across container recreates
- Project workspace (`~/workspace/<name>/`) accessible from both host IDEs and inside the container
