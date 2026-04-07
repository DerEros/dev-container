## 1. Dockerfile

- [x] 1.1 Create `Dockerfile` based on Ubuntu 24.04
- [x] 1.2 Install base packages: curl, wget, sudo, git, zsh, tmux, unzip, ca-certificates, gnupg, lsb-release
- [x] 1.3 Create `dev` user (UID 1000) with passwordless sudo and zsh as default shell
- [x] 1.4 Install oh-my-zsh, Powerlevel10k theme, zsh-autosuggestions, zsh-syntax-highlighting for `dev` user
- [x] 1.5 Install Node.js LTS and npm via NodeSource
- [x] 1.6 Install Angular CLI globally via npm
- [x] 1.7 Install GitHub CLI (`gh`) via official apt repository
- [x] 1.8 Install Docker CE (CLI + daemon) via official apt repository
- [x] 1.9 Install SDKMAN for `dev` user, then install Java (Temurin), Maven, Gradle
- [x] 1.10 Install pyenv for `dev` user, then install Python 3 and set as global
- [x] 1.11 Install Azure CLI via official install script
- [x] 1.12 Install kubectl via official apt repository
- [x] 1.13 Install Terraform via HashiCorp apt repository
- [x] 1.14 Install Claude Code CLI globally via npm
- [x] 1.15 Set working directory to `/home/dev/workspace` and default user to `dev`
- [x] 1.16 Verify image builds cleanly and all `--version` checks pass

## 2. Docker Compose

- [x] 2.1 Create `docker-compose.yml` with a single `dev` service
- [x] 2.2 Configure container name as `dev-${PROJECT_NAME}`
- [x] 2.3 Add workspace volume mount: `${WORKSPACE_PATH}:/home/dev/workspace`
- [x] 2.4 Add Claude config volume mount: `${CLAUDE_CONFIG_PATH}:/home/dev/.claude`
- [x] 2.5 Set `privileged: true` for Docker-in-Docker
- [x] 2.6 Set `stdin_open: true` and `tty: true` for interactive shell

## 3. Spin script

- [x] 3.1 Create `spin.sh` with shebang and strict mode (`set -euo pipefail`)
- [x] 3.2 Resolve script directory using `$(dirname "$(realpath "$0")")` for self-location
- [x] 3.3 Derive project name from first argument or `basename "$PWD"`
- [x] 3.4 Set host path variables: `WORKSPACE` and `CLAUDE_CONFIG`
- [x] 3.5 Create host directories with `mkdir -p` if they don't exist
- [x] 3.6 Check if container `dev-<name>` exists (running or stopped) via `docker ps -a`
- [x] 3.7 If running: `docker exec -it dev-<name> zsh`
- [x] 3.8 If stopped: `docker start dev-<name>` then exec in
- [x] 3.9 If absent: export env vars and run `docker compose up -d`, then exec in
- [x] 3.10 Make `spin.sh` executable (`chmod +x`)

## 4. Verification

- [x] 4.1 Build the image and confirm it builds without errors
- [x] 4.2 Run `spin.sh test-project` and confirm it creates host directories and drops into zsh as `dev`
- [x] 4.3 Verify all tools present: `node`, `python3`, `java`, `mvn`, `gradle`, `ng`, `git`, `gh`, `docker`, `az`, `kubectl`, `terraform`, `claude`
- [x] 4.4 Verify Claude config mount: create a file in `/home/dev/.claude/` and confirm it appears on host
- [x] 4.5 Verify workspace mount: create a file in `/home/dev/workspace/` and confirm it appears on host
- [x] 4.6 Stop the container, run `spin.sh test-project` again, confirm it reattaches without recreating
- [x] 4.7 Verify Docker-in-Docker: run `start-docker` inside container, then `docker run hello-world`
