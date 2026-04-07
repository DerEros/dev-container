## Requirements

### Requirement: Project name argument
`spin.sh` SHALL accept a single positional argument: the project name. If no argument is provided, it SHALL use the name of the current working directory as the project name.

#### Scenario: Name provided explicitly
- **WHEN** `spin.sh my-project` is run
- **THEN** the container and host directories use `my-project` as the name

#### Scenario: Name defaults to current directory
- **WHEN** `spin.sh` is run with no arguments from `~/workspace/foo`
- **THEN** the container and host directories use `foo` as the name

### Requirement: Host directory initialisation
Before starting the container, `spin.sh` SHALL create the required host directories if they do not already exist: `~/workspace/<name>/` and `~/.dev-containers/<name>/.claude/`.

#### Scenario: Directories created on first run
- **WHEN** `spin.sh my-project` is run for the first time
- **THEN** `~/workspace/my-project/` and `~/.dev-containers/my-project/.claude/` exist on the host after the script runs

#### Scenario: Existing directories not overwritten
- **WHEN** the directories already exist with content
- **THEN** their contents are preserved

### Requirement: Reattach-or-create semantics
`spin.sh` SHALL check whether a container named `dev-<name>` already exists. If it exists and is running, it SHALL exec a new zsh session into it. If it exists but is stopped, it SHALL start it and then exec in. If it does not exist, it SHALL create it via `docker compose up` and then exec in.

#### Scenario: Fresh container created
- **WHEN** no container named `dev-<name>` exists
- **THEN** `spin.sh` creates one and drops the user into zsh

#### Scenario: Running container reattached
- **WHEN** a container named `dev-<name>` is already running
- **THEN** `spin.sh` execs a new shell into it without recreating it

#### Scenario: Stopped container restarted
- **WHEN** a container named `dev-<name>` exists but is stopped
- **THEN** `spin.sh` starts it and drops the user into zsh

### Requirement: Volume mounts
The container SHALL be started with exactly two volume mounts: the project workspace and the per-project Claude config directory, as defined in the volume-layout spec.

#### Scenario: Workspace mounted
- **WHEN** the container is running
- **THEN** `/home/dev/workspace/` inside the container reflects `~/workspace/<name>/` on the host

#### Scenario: Claude config mounted
- **WHEN** the container is running
- **THEN** `/home/dev/.claude/` inside the container reflects `~/.dev-containers/<name>/.claude/` on the host

### Requirement: Privileged mode
The container SHALL be started with `--privileged` to enable Docker-in-Docker.

#### Scenario: Docker works inside container
- **WHEN** the container is running
- **THEN** `docker run hello-world` executes successfully inside it

### Requirement: Script self-location
`spin.sh` SHALL resolve its own location to find the `docker-compose.yml` sibling file, so it works correctly regardless of the caller's working directory.

#### Scenario: Called from any directory
- **WHEN** `spin.sh` is called via a symlink or from a different working directory
- **THEN** it still finds and uses the correct `docker-compose.yml`
