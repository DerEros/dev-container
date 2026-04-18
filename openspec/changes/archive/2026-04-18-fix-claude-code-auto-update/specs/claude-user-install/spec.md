## ADDED Requirements

### Requirement: Claude Code installed in user-owned npm prefix
The dev container SHALL install Claude Code (`@anthropic-ai/claude-code`) into a user-owned npm prefix at `~/.npm-global`, separate from the root-owned system npm prefix. The `dev` user SHALL have full write access to this prefix.

#### Scenario: Claude Code binary is on PATH
- **WHEN** the `dev` user opens a shell in the container
- **THEN** `claude` resolves to `~/.npm-global/bin/claude`

#### Scenario: Claude Code auto-update succeeds
- **WHEN** Claude Code attempts to update itself in a running container
- **THEN** the update completes without permission errors

#### Scenario: Root npm prefix is unaffected
- **WHEN** the container image is built
- **THEN** `@anthropic-ai/claude-code` is NOT present in the root npm global prefix (`npm list -g` as root does not list it)

### Requirement: User npm prefix configured persistently
The `dev` user's npm configuration SHALL set `prefix` to `~/.npm-global` so that any future `npm install -g` invocations by the `dev` user also target the user-owned prefix.

#### Scenario: npm prefix is set for dev user
- **WHEN** the `dev` user runs `npm config get prefix`
- **THEN** the output is `/home/dev/.npm-global`

### Requirement: User npm bin directory on PATH
The directory `~/.npm-global/bin` SHALL appear in the `dev` user's `PATH` in `.zshrc`, ahead of system binary paths.

#### Scenario: PATH contains user npm bin
- **WHEN** the `dev` user opens a new zsh shell
- **THEN** `echo $PATH` includes `/home/dev/.npm-global/bin`
