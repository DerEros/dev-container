#!/usr/bin/env bash
set -euo pipefail

# Resolve script location regardless of symlinks or caller's CWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
