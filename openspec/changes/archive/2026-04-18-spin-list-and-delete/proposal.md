## Why

`spin.sh` can create, start, and attach to dev containers, but offers no way to inspect or clean up existing environments. As the number of projects grows, users have no ergonomic way to see what containers exist or remove ones that are no longer needed.

## What Changes

- Add `spin.sh list` subcommand to display all existing dev containers and their state
- Add `spin.sh delete <name>` subcommand to remove a container with a y/N confirmation guard
- Add `--purge` flag to `spin.sh delete` to also remove host-side workspace and config directories, with a two-step confirmation (y/N prompt + type the name)
- `delete` and `delete --purge` are idempotent — missing containers or directories are silently ignored

## Capabilities

### New Capabilities

- `spin-list`: List all dev containers managed by spin.sh, showing project name and running/stopped status
- `spin-delete`: Remove a dev container (and optionally its host directories) with appropriate confirmation guards

### Modified Capabilities

- `spin-script`: The script gains subcommand dispatch — `$1` is now checked against reserved subcommand names (`list`, `delete`) before being treated as a project name

## Impact

- `spin.sh`: subcommand dispatch block added, two new command handlers
- `openspec/specs/spin-script/spec.md`: updated with subcommand dispatch requirement
- No changes to `docker-compose.yml`, `Dockerfile`, or any container internals
