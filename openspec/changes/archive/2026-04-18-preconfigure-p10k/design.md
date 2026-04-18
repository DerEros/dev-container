## Context

The dev container image is built from a single `Dockerfile` using `docker-compose.yml` with build context `.` (the repo root). Step 17 installs oh-my-zsh and clones Powerlevel10k as a custom theme, patching `.zshrc` to set `ZSH_THEME="powerlevel10k/powerlevel10k"`. The `.zshrc` template already contains `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh` — so the config is sourced automatically if the file exists. When it doesn't, p10k runs the interactive wizard on first shell start.

The user has an existing, preferred `.p10k.zsh` (1713 lines, nerdfont-v3 + powerline, lean 8-color style, instant prompt verbose) that represents the desired end state.

## Goals / Non-Goals

**Goals:**
- Suppress the p10k wizard in all fresh containers
- Ship a specific, version-controlled prompt style that matches the user's preference
- Establish a `config/` directory as the canonical location for curated dotfiles baked into the image

**Non-Goals:**
- Dynamic per-container prompt customisation
- Supporting multiple prompt style variants
- Replacing the full `.zshrc` with a managed version

## Decisions

### Copy from repo file vs inline heredoc

**Decision**: COPY a file from `config/p10k.zsh` in the build context.

The config is 1713 lines. Embedding it inline in the Dockerfile (via `printf` or heredoc) would make the Dockerfile unreadable and hard to diff. A separate file is version-controlled, diffable, and easy to update.

Alternatives considered:
- `RUN curl ...` to fetch from a gist — adds external dependency, breaks offline builds
- Inline heredoc in Dockerfile — impractical at this size

### Placement in Dockerfile

**Decision**: Add the COPY as a sub-step of step 17, immediately after the oh-my-zsh/p10k install block, while still in the `USER dev` section.

The file must land at `/home/dev/.p10k.zsh` and be owned by `dev`. Running `COPY` after switching to `USER dev` achieves this without a `chown`. Placing it adjacent to the p10k install keeps related configuration co-located.

### config/ directory naming

**Decision**: Use `config/` at the repo root as the home for all dotfiles shipped into the image.

This is a neutral, conventional name. Future files (e.g. a managed `.tmuxrc` snippet, a custom `.zshrc` additions file) fit naturally here without the directory name becoming stale.

## Risks / Trade-offs

- **Wizard inaccessible by default** → The wizard can still be invoked manually with `p10k configure` inside any container. The baked config is not locked.
- **Config updates require image rebuild** → Editing `config/p10k.zsh` and rebuilding is the intentional update path. No mitigation needed; this is the desired workflow.
- **Instant-prompt cache** → p10k's instant-prompt feature writes a cache to `~/.cache/`. This is inside the container's writable layer and regenerates per session. No issue.

## Migration Plan

1. Add `config/p10k.zsh` to the repo (copy of `~/.p10k.zsh`)
2. Add `COPY` line to Dockerfile
3. Rebuild image: `docker build -t dev-container .`
4. New containers will have the config baked in; existing running containers are unaffected until recreated

Rollback: remove the `COPY` line and rebuild.
