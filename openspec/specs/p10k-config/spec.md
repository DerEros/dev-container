# Spec: p10k-config

## Purpose

Defines how Powerlevel10k is pre-configured in the dev container image so that containers start with a ready-to-use prompt without running the interactive setup wizard.

## Requirements

### Requirement: Pre-configured Powerlevel10k ships with the image
The dev container image SHALL include a `~/.p10k.zsh` file baked in at build time, sourced from `config/p10k.zsh` in the repository. The file SHALL reflect the user's preferred prompt style (nerdfont-v3 + powerline, lean 8-color, instant prompt verbose) as established by the wizard-generated config.

#### Scenario: Fresh container starts without wizard
- **WHEN** a new dev container is created and the user starts a zsh session for the first time
- **THEN** the Powerlevel10k configuration wizard SHALL NOT appear and the prompt SHALL render using the baked-in config

#### Scenario: Config file is present after image build
- **WHEN** the Docker image is built from the Dockerfile
- **THEN** the file `~/.p10k.zsh` SHALL exist in the image with non-zero content

#### Scenario: Manual reconfiguration remains possible
- **WHEN** a user runs `p10k configure` inside a running container
- **THEN** the wizard SHALL run and overwrite `~/.p10k.zsh` for the duration of that container session

### Requirement: config/ directory holds curated dotfiles
The repository SHALL contain a `config/` directory at the root that serves as the canonical location for dotfiles copied into the image at build time.

#### Scenario: p10k config is tracked in version control
- **WHEN** a developer clones the repository
- **THEN** `config/p10k.zsh` SHALL be present and usable as a Docker build context file
