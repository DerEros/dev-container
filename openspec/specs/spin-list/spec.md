## Requirements

### Requirement: List subcommand
`spin.sh list` SHALL display all dev containers managed by spin.sh, showing the project name and current state (running or stopped). No arguments are accepted after `list`.

#### Scenario: Containers exist
- **WHEN** `spin.sh list` is run and one or more containers named `dev-*` exist
- **THEN** each is printed as `<project-name>    <status>` where status is `running` or `stopped`

#### Scenario: No containers exist
- **WHEN** `spin.sh list` is run and no containers named `dev-*` exist
- **THEN** no output is produced and the script exits successfully

#### Scenario: Mixed running and stopped
- **WHEN** some containers are running and others are stopped
- **THEN** all are listed with their respective statuses
