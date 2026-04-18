## MODIFIED Requirements

### Requirement: Project name argument
`spin.sh` SHALL accept a single positional argument: the project name. If no argument is provided, it SHALL use the name of the current working directory as the project name. The words `list` and `delete` are reserved subcommand names and SHALL NOT be usable as project names via this script.

#### Scenario: Name provided explicitly
- **WHEN** `spin.sh my-project` is run
- **THEN** the container and host directories use `my-project` as the name

#### Scenario: Name defaults to current directory
- **WHEN** `spin.sh` is run with no arguments from `~/workspace/foo`
- **THEN** the container and host directories use `foo` as the name

#### Scenario: Reserved word intercepted as subcommand
- **WHEN** `spin.sh list` or `spin.sh delete` is run
- **THEN** the argument is treated as a subcommand, not a project name
