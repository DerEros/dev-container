## MODIFIED Requirements

### Requirement: Shell environment
The image SHALL include zsh, tmux, oh-my-zsh, and the Powerlevel10k theme. Standard oh-my-zsh plugins (git, zsh-autosuggestions, zsh-syntax-highlighting) SHALL be pre-installed. The default zsh theme SHALL be Powerlevel10k. A tmux configuration file SHALL be pre-installed at `/home/dev/.tmux.conf` with mouse mode enabled.

#### Scenario: Zsh is the login shell
- **WHEN** a user connects to the container
- **THEN** zsh starts automatically with oh-my-zsh and Powerlevel10k loaded

#### Scenario: tmux mouse mode enabled by default
- **WHEN** the `dev` user starts a new tmux session
- **THEN** mouse mode is active without any manual configuration
