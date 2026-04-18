#!/usr/bin/env bash
set -euo pipefail

# Resolve script location through any symlink chain, works on Linux and macOS
SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$SOURCE" ]]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# ---------------------------------------------------------------------------
# Subcommand dispatch — check $1 before treating it as a project name
# ---------------------------------------------------------------------------
CMD="${1:-}"

case "${CMD}" in

  list)
    # Print all dev-* containers with running/stopped status
    docker ps -a \
      --filter "name=^dev-" \
      --format "{{.Names}}\t{{.Status}}" \
    | while IFS=$'\t' read -r name status; do
        project="${name#dev-}"
        if [[ "${status}" == Up* ]]; then
          state="running"
        else
          state="stopped"
        fi
        printf "%-30s %s\n" "${project}" "${state}"
      done
    exit 0
    ;;

  delete)
    PROJECT_NAME="${2:-}"
    if [[ -z "${PROJECT_NAME}" ]]; then
      echo "Usage: spin.sh delete <name> [--purge]" >&2
      exit 1
    fi

    PURGE=false
    for arg in "${@:3}"; do
      [[ "${arg}" == "--purge" ]] && PURGE=true
    done

    CONTAINER_NAME="dev-${PROJECT_NAME}"
    WORKSPACE="${HOME}/workspace/${PROJECT_NAME}"
    CONTAINER_ROOT="${HOME}/.dev-containers/${PROJECT_NAME}"

    # Check container existence before prompting
    CONTAINER_EXISTS=false
    if docker ps -a --filter "name=^${CONTAINER_NAME}$" --format '{{.Names}}' \
        | grep -q "^${CONTAINER_NAME}$"; then
      CONTAINER_EXISTS=true
    fi

    if [[ "${CONTAINER_EXISTS}" == false && "${PURGE}" == false ]]; then
      echo "Container ${CONTAINER_NAME} not found."
      exit 0
    fi

    # First confirmation — always required
    read -r -p "Remove container ${CONTAINER_NAME}? [y/N] " confirm
    if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
      echo "Aborted."
      exit 0
    fi

    # Remove container if it exists
    if [[ "${CONTAINER_EXISTS}" == true ]]; then
      echo "→ Removing container: ${CONTAINER_NAME}"
      docker rm -f "${CONTAINER_NAME}"
    fi

    if [[ "${PURGE}" == true ]]; then
      # Second confirmation — type the project name
      read -r -p "Type '${PROJECT_NAME}' to confirm purge of host directories: " name_confirm
      if [[ "${name_confirm}" != "${PROJECT_NAME}" ]]; then
        echo "Name did not match — purge aborted."
        exit 0
      fi

      # Remove host directories if they exist (idempotent)
      if [[ -d "${WORKSPACE}" ]]; then
        echo "→ Removing workspace: ${WORKSPACE}"
        rm -rf "${WORKSPACE}"
      fi
      if [[ -d "${CONTAINER_ROOT}" ]]; then
        echo "→ Removing config: ${CONTAINER_ROOT}"
        rm -rf "${CONTAINER_ROOT}"
      fi
    fi

    exit 0
    ;;

esac

# ---------------------------------------------------------------------------
# Default: attach-or-create a dev container
# ---------------------------------------------------------------------------

# Project name: first arg or name of current directory
PROJECT_NAME="${1:-$(basename "$PWD")}"

# Host paths
WORKSPACE="${HOME}/workspace/${PROJECT_NAME}"
CLAUDE_CONFIG="${HOME}/.dev-containers/${PROJECT_NAME}/.claude"
CONTAINER_NAME="dev-${PROJECT_NAME}"

# Create host directories if they don't exist
mkdir -p "${WORKSPACE}" "${CLAUDE_CONFIG}"

# Determine container state and act accordingly
if docker ps --filter "name=^${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  # Running — attach a new shell
  echo "→ Attaching to running container: ${CONTAINER_NAME}"
  docker exec -it "${CONTAINER_NAME}" zsh

elif docker ps -a --filter "name=^${CONTAINER_NAME}$" --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  # Stopped — start then attach
  echo "→ Starting stopped container: ${CONTAINER_NAME}"
  docker start "${CONTAINER_NAME}"
  docker exec -it "${CONTAINER_NAME}" zsh

else
  # Doesn't exist — create via compose
  echo "→ Creating new container: ${CONTAINER_NAME}"
  PROJECT_NAME="${PROJECT_NAME}" \
  WORKSPACE_PATH="${WORKSPACE}" \
  CLAUDE_CONFIG_PATH="${CLAUDE_CONFIG}" \
  docker compose \
    --file "${SCRIPT_DIR}/docker-compose.yml" \
    --project-name "${PROJECT_NAME}" \
    up -d
  docker exec -it "${CONTAINER_NAME}" zsh
fi
