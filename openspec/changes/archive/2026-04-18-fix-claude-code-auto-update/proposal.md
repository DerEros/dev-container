## Why

Claude Code is installed as root inside the dev container, placing it in a root-owned npm global directory. When Claude Code attempts to auto-update, it fails with a permission error because the `dev` user cannot write to that directory — resulting in a persistent red error message on every session.

## What Changes

- Remove `@anthropic-ai/claude-code` from the root-level `npm install -g` step in the Dockerfile
- Configure a user-local npm prefix (`~/.npm-global`) for the `dev` user
- Install `@anthropic-ai/claude-code` as the `dev` user into that prefix
- Add `~/.npm-global/bin` to `PATH` in `.zshrc`

## Capabilities

### New Capabilities

- `claude-user-install`: Claude Code installed in a user-owned npm prefix, enabling self-update without elevated privileges

### Modified Capabilities

_(none — no existing spec-level requirements are changing)_

## Impact

- `Dockerfile`: Two sections modified (root npm install step, new user-space install step)
- No impact on other globally installed npm tools (Angular CLI, OpenSpec, TypeScript, Pyright) — these remain root-installed and do not self-update
- Claude Code auto-update will work correctly in running containers going forward
