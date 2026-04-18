## Context

The dev container ships tmux but has no `.tmux.conf` for the `dev` user, so mouse mode is off by default. The fix is a single config file baked into the image.

## Goals / Non-Goals

**Goals:**
- Enable tmux mouse mode for all fresh containers without any manual configuration

**Non-Goals:**
- Full tmux configuration (key bindings, status bar, etc.)
- User-overridable config layering

## Decisions

**Ship a static `config/tmux.conf` and COPY it via Dockerfile**
- Alternative: set via a `RUN echo` command in the Dockerfile — less readable and harder to extend later
- Alternative: install via dotfiles in the entrypoint — unnecessary complexity for a single setting

The config file approach is consistent with how `config/p10k.zsh` is handled in the parallel `preconfigure-p10k` change.

## Risks / Trade-offs

- None significant. Mouse mode is additive and does not affect keyboard-only workflows.
