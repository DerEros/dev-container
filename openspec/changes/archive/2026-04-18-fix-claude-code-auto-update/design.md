## Context

The dev container Dockerfile installs all npm global tools as `root` in a single step (step 6). This places packages — including Claude Code — in a root-owned global prefix (typically `/usr/local/lib/node_modules`). The container's primary user `dev` has broad sudo access but Claude Code's auto-update mechanism does not use sudo; it writes directly to the npm global prefix and fails with EACCES.

All other globally installed tools (Angular CLI, OpenSpec, TypeScript, Pyright) are static — they never attempt to self-update, so the root-owned location is not a problem for them. Claude Code is unique in that it has a built-in auto-update mechanism that runs as the current user.

## Goals / Non-Goals

**Goals:**
- Claude Code can update itself in a running container without errors
- The install is isolated in a user-owned location distinct from the root-installed system tools
- PATH is configured so the user-installed `claude` binary takes precedence

**Non-Goals:**
- Migrating other npm globals (Angular CLI, OpenSpec, etc.) to user-space — they don't self-update and don't need it
- Switching Node.js to a user-managed version manager (nvm, n) — the NodeSource system install stays as-is
- Pinning or managing Claude Code versions — auto-update handles this

## Decisions

### Decision: User-local npm prefix at `~/.npm-global`

Claude Code is installed after `USER dev` using a dedicated npm prefix directory at `~/.npm-global`, configured via `npm config set prefix`.

**Alternatives considered:**
- `chown` the root npm prefix to `dev` — simpler, but dissolves the boundary between system tools and user tools, inviting ad-hoc upgrades of root-installed packages
- Use `nvm` for all Node.js — clean but large scope change; not worth it for one package

`~/.npm-global` is the conventional user-local npm prefix path and requires no third-party tooling.

### Decision: Keep root install step for all other npm globals

Angular CLI, OpenSpec, TypeScript, Pyright, and language servers remain in the root npm step. They are system-level tools — consistent across any user — and do not self-update.

### Decision: PATH entry prepended in `.zshrc`

`~/.npm-global/bin` is added to `PATH` in `.zshrc` ahead of system paths so the user-installed `claude` binary is always resolved first.

## Risks / Trade-offs

- **Two npm global locations**: `npm list -g` as root and as `dev` will show different sets. This is intentional but could be confusing. → Mitigation: a comment in the Dockerfile step makes the intent explicit.
- **`npm config set prefix` affects all future user-level `npm install -g`**: If the user installs other global tools interactively, they go to `~/.npm-global` rather than the system prefix. This is acceptable and consistent for a personal dev container. → No mitigation needed.
- **Auto-update requires internet access**: Claude Code's update runs in the container at runtime. The container must have outbound internet access for updates to succeed. → This is already a baseline assumption of the container setup.
