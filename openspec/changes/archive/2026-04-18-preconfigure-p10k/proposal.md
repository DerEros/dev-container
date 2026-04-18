## Why

Every fresh dev container triggers the Powerlevel10k configuration wizard on first shell start because no `~/.p10k.zsh` exists in the image. This is disruptive — it interrupts workflow and requires manual setup steps that produce the same result every time.

## What Changes

- A `config/` directory is introduced at the repo root to hold curated dotfiles shipped with the image
- The user's existing `.p10k.zsh` (wizard-generated, nerdfont-v3 + powerline lean style) is committed as `config/p10k.zsh`
- The Dockerfile gains a single `COPY` line after the oh-my-zsh/p10k install step to place the config at `~/.p10k.zsh` in the image

## Capabilities

### New Capabilities
- `p10k-config`: A versioned, repo-tracked Powerlevel10k configuration file that is baked into the dev container image, suppressing the setup wizard on first shell start

### Modified Capabilities
<!-- No existing spec-level behavior changes -->

## Impact

- `Dockerfile`: One new `COPY config/p10k.zsh /home/dev/.p10k.zsh` line in the user-layer section (after step 17)
- `config/p10k.zsh`: New file added to the repo (1713 lines, read-only concern — not executed at build time, only sourced at shell start)
- No changes to `docker-compose.yml`, `spin.sh`, or existing volume mounts
- Requires a Docker image rebuild to take effect
