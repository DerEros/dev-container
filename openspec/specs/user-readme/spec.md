# Spec: User-Facing README

## Purpose

This capability covers the user-facing README for the dev container repository. It establishes what the README must communicate to developers who discover or use the project: what the container is, what tools it includes, how to get started, and how to customise it.

## Requirements

### Requirement: Project description and use case
The README SHALL open with a concise description of what the dev container is and who it is for, establishing context before any instructions.

#### Scenario: Reader understands the purpose
- **WHEN** a colleague opens the README for the first time
- **THEN** they SHALL be able to identify that this is a Docker-based development environment with pre-installed toolchains and Claude Code, intended for developers who want a consistent, isolated workspace per project

### Requirement: Included tools inventory
The README SHALL list all major tools and runtimes bundled in the image, grouped by category, using a bullet list format.

#### Scenario: Developer checks if their stack is covered
- **WHEN** a developer reads the tools section
- **THEN** they SHALL find all language runtimes (Node.js, Python, Java, Rust, .NET), cloud/infra CLIs (Azure CLI, kubectl, Terraform, GitHub CLI), Docker-in-Docker, Claude Code, and shell tooling (zsh, oh-my-zsh, Powerlevel10k, tmux) listed

### Requirement: Prerequisites with platform constraints
The README SHALL list prerequisites for using the container, and SHALL prominently call out the arm64 architecture constraint and the OrbStack/macOS context for Docker-in-Docker.

#### Scenario: User on x86 reads prerequisites
- **WHEN** an x86 user reads the prerequisites section
- **THEN** they SHALL see a clear notice that the Godot binary is bundled as arm64 and they will need to swap it in the Dockerfile

#### Scenario: User on non-OrbStack Docker reads prerequisites
- **WHEN** a user running Docker Desktop or a Linux Docker daemon reads the prerequisites
- **THEN** they SHALL see a notice that Docker-in-Docker uses the vfs storage driver, tested on OrbStack/macOS, and may need adjustment on other setups

### Requirement: Getting started instructions
The README SHALL provide step-by-step instructions to clone the repository, build the image, and start a project shell using `spin.sh`.

#### Scenario: First-time setup
- **WHEN** a user follows the getting started section from scratch
- **THEN** they SHALL be able to run `git clone`, `docker build -t dev-container .`, and `./spin.sh <project-name>` in sequence and land in a working container shell

### Requirement: spin.sh behaviour explained
The README SHALL describe the create-or-resume-or-attach logic of `spin.sh`, including the per-project workspace and Claude config isolation it provides.

#### Scenario: User understands what spin.sh does on repeat invocations
- **WHEN** a user reads the spin.sh section
- **THEN** they SHALL understand that re-running `spin.sh <project-name>` attaches to an existing container if running, restarts it if stopped, or creates a fresh one if it does not exist — and that workspace and Claude config are isolated per project name

### Requirement: Dotfiles customization guidance
The README SHALL provide guidance on customizing the shell environment via dotfiles, covering the pre-configured Powerlevel10k config and zshrc modifications.

#### Scenario: User wants to apply their own shell config
- **WHEN** a user reads the customization section
- **THEN** they SHALL learn how to replace `config/p10k.zsh` with their own Powerlevel10k config and how to add personal aliases or exports to the Dockerfile's zshrc setup steps or via a mounted dotfiles volume
