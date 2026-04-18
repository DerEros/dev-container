## Requirements

### Requirement: Delete subcommand
`spin.sh delete <name>` SHALL remove the container named `dev-<name>` after prompting the user for confirmation. The operation SHALL be idempotent — if the container does not exist, the script exits successfully without error.

#### Scenario: Container exists and user confirms
- **WHEN** `spin.sh delete my-project` is run and container `dev-my-project` exists
- **AND** the user responds `y` or `Y` at the confirmation prompt
- **THEN** the container is stopped (if running) and removed

#### Scenario: Container does not exist
- **WHEN** `spin.sh delete my-project` is run and no container named `dev-my-project` exists
- **THEN** the script exits successfully with no error

#### Scenario: User declines confirmation
- **WHEN** the user responds with anything other than `y` or `Y`
- **THEN** no container is removed and the script exits without error

#### Scenario: Name argument missing
- **WHEN** `spin.sh delete` is run with no name argument
- **THEN** the script prints a usage error and exits with a non-zero status

### Requirement: Purge flag
`spin.sh delete <name> --purge` SHALL additionally remove the host-side directories `~/workspace/<name>/` and `~/.dev-containers/<name>/` after a two-step confirmation. Each absent directory is silently skipped.

#### Scenario: Purge with full confirmation
- **WHEN** `spin.sh delete my-project --purge` is run
- **AND** the user confirms `y` at the first prompt
- **AND** the user types `my-project` at the second prompt
- **THEN** the container (if present), `~/workspace/my-project/`, and `~/.dev-containers/my-project/` are all removed

#### Scenario: Purge with missing host directories
- **WHEN** `spin.sh delete my-project --purge` is run
- **AND** `~/workspace/my-project/` or `~/.dev-containers/my-project/` do not exist
- **THEN** the missing directories are silently skipped and no error is raised

#### Scenario: Purge aborted at name confirmation
- **WHEN** the user types a name that does not match `my-project` at the second prompt
- **THEN** no host directories are removed and the script exits without error
