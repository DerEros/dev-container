## Purpose

TBD — Specifies the pre-installed tmux configuration for the `dev` user in the dev container image.

## Requirements

### Requirement: Pre-installed tmux configuration
The image SHALL include a `.tmux.conf` for the `dev` user located at `/home/dev/.tmux.conf`. The file SHALL enable mouse mode (`set -g mouse on`).

#### Scenario: tmux config file present
- **WHEN** the container starts
- **THEN** `/home/dev/.tmux.conf` exists and is readable by the `dev` user

#### Scenario: Mouse mode active in new tmux session
- **WHEN** the `dev` user starts a new tmux session
- **THEN** mouse mode is enabled without any additional configuration
