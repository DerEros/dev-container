## Why

tmux inside the dev container requires mouse support to be explicitly enabled; without it, scrolling, pane selection, and window resizing with the mouse do not work. Enabling mouse mode by default removes a recurring friction point every time a fresh container is started.

## What Changes

- Add a `.tmux.conf` for the `dev` user with `set -g mouse on`
- Copy the file into the container image via the Dockerfile

## Capabilities

### New Capabilities
- `tmux-config`: A pre-installed tmux configuration file for the `dev` user that enables mouse mode by default.

### Modified Capabilities
- `dev-container-image`: The shell environment requirement expands to include a pre-installed tmux config enabling mouse mode.

## Impact

- `Dockerfile`: One new `COPY` instruction
- New file `config/tmux.conf` added to the repo
- No dependency changes; no breaking changes
