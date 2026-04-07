## Requirements

### Requirement: Workspace directory convention
Each project SHALL have a dedicated workspace directory on the macOS host at `~/workspace/<name>/`. This directory SHALL be mounted into the container at `/home/dev/workspace/`. It contains the project's source code and is accessible from both host IDEs and the container simultaneously.

#### Scenario: Workspace visible from host IDE
- **WHEN** a file is created inside the container at `/home/dev/workspace/foo.txt`
- **THEN** it is visible on the host at `~/workspace/<name>/foo.txt`

#### Scenario: Workspace visible from container
- **WHEN** a file is created on the host at `~/workspace/<name>/bar.txt`
- **THEN** it is visible inside the container at `/home/dev/workspace/bar.txt`

### Requirement: Per-project Claude config directory
Each project SHALL have a dedicated Claude config directory on the macOS host at `~/.dev-containers/<name>/.claude/`. This directory SHALL be mounted into the container at `/home/dev/.claude/`. It persists Claude auth tokens, settings, custom commands, and skills across container recreates.

#### Scenario: Claude auth survives container recreate
- **WHEN** a container is destroyed and recreated from the same image
- **THEN** Claude's auth state is restored from the mounted `.claude/` directory

#### Scenario: Custom commands persist
- **WHEN** a custom Claude command is added inside the container
- **THEN** it persists in `~/.dev-containers/<name>/.claude/` on the host and survives container recreate

### Requirement: No other host paths mounted
The container SHALL NOT mount any other directories from the host filesystem. All other container state (tools, OS, shell config) is provided by the image.

#### Scenario: Host home directory not accessible
- **WHEN** the container is running
- **THEN** the host's `~/` (outside workspace and .claude) is not accessible from inside the container

### Requirement: Host directories created automatically
Both host directories SHALL be created by `spin.sh` before container startup if they do not already exist. The user SHALL NOT need to create them manually.

#### Scenario: First-run auto-creation
- **WHEN** `spin.sh <name>` is run and neither host directory exists
- **THEN** both are created and the container starts successfully
