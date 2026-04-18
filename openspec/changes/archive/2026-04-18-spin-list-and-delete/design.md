## Context

`spin.sh` is a single-file bash script that manages dev containers. Currently `$1` is unconditionally treated as a project name. Adding `list` and `delete` subcommands requires a dispatch layer before the project-name logic, plus two new command handlers.

The script runs on the host (not inside a container), so all Docker operations are plain `docker` CLI calls. No external dependencies are introduced.

## Goals / Non-Goals

**Goals:**
- Add subcommand dispatch to `spin.sh` as a thin prefix check
- Implement `list`: enumerate `dev-*` containers, show project name + status
- Implement `delete <name>`: remove container only, guarded by y/N prompt
- Implement `delete <name> --purge`: additionally remove host dirs, guarded by y/N + name confirmation
- All destructive operations are idempotent — missing containers or directories are silently ignored

**Non-Goals:**
- Interactive container selection (e.g. fzf picker)
- Bulk delete
- Removing compose networks or anonymous volumes not associated with a named container
- Any changes to the container image or compose file

## Decisions

### Subcommand dispatch via reserved-word prefix check

`$1` is checked against `list` and `delete` before the existing project-name path. This is a minimal change — one `case` block at the top of the script.

**Alternative considered**: flags (`--list`, `--delete`). Rejected because subcommands are more ergonomic for an interactive tool and the naming collision risk is self-enforcing (you cannot create a project named `list` via `spin.sh`).

### `list` uses `docker ps -a` with `name=^dev-` filter

```
docker ps -a \
  --filter "name=^dev-" \
  --format "{{.Names}}\t{{.Status}}"
```

Project name is derived by stripping the `dev-` prefix. Status is the raw Docker status string trimmed to `running` or `stopped`.

**Alternative considered**: parsing `docker compose ls`. Rejected — compose project names don't reliably map 1:1 to containers in all states.

### `delete` confirmation strategy

- Simple delete: single `read -r -p "Remove container dev-<name>? [y/N] "` prompt. Proceed only on explicit `y` or `Y`.
- `--purge`: additional `read -r -p "Type '<name>' to confirm purge of host directories: "` check after the y/N. Two-step because host workspace deletion is irreversible.

### `--purge` host directory removal uses `rm -rf` with existence guard

```bash
[[ -d "${WORKSPACE}" ]] && rm -rf "${WORKSPACE}"
[[ -d "${CLAUDE_CONFIG%/.claude}" ]] && rm -rf "${CLAUDE_CONFIG%/.claude}"
```

Silent no-op if directories don't exist — satisfies idempotency requirement.

## Risks / Trade-offs

- **`dev-` prefix assumption** → Any container manually named with a `dev-` prefix will appear in `list`. Acceptable — the prefix is the convention; users who bypass `spin.sh` opt out of these guarantees.
- **y/N is case-sensitive on `y`/`Y` only** → This is standard shell convention; accidental confirmations are more dangerous than slightly awkward UX.
- **`rm -rf` on workspace** → Mitigated by two-step purge confirmation. The workspace path is always `~/workspace/<name>/`, never `/` or `~`.

## Migration Plan

Drop-in replacement — no existing behaviour changes. Users calling `spin.sh <name>` are unaffected. No rollback needed; removing the new `case` branch restores previous behaviour exactly.
