## ADDED Requirements

### Requirement: Godot headless binary available in container
The container SHALL provide the Godot 4.6.2 Linux arm64 `.NET` (mono) build at `/usr/local/bin/godot`, executable by all users.

#### Scenario: Godot binary is executable
- **WHEN** any user runs `godot --version` inside the container
- **THEN** the command exits successfully and prints a version string containing `4.6.2.stable.mono`

#### Scenario: Headless mode works
- **WHEN** a user runs `godot --headless --quit` inside the container
- **THEN** the process exits with code 0 without requiring a display

### Requirement: GODOT_BIN environment variable is set
The container SHALL export `GODOT_BIN=/usr/local/bin/godot` so gdUnit4Net can locate the binary without per-project configuration.

#### Scenario: Environment variable is present in shell
- **WHEN** a user runs `echo $GODOT_BIN` inside the container
- **THEN** the output is `/usr/local/bin/godot`

#### Scenario: gdUnit4Net resolves binary path automatically
- **WHEN** `dotnet test` is executed in a Godot C# project with gdUnit4Net
- **THEN** gdUnit4Net uses the binary at `$GODOT_BIN` without requiring a `.runsettings` override
