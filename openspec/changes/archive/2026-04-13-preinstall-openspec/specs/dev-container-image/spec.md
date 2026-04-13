## ADDED Requirements

### Requirement: OpenSpec CLI
The image SHALL include the `openspec` CLI installed and available on the PATH for the `dev` user.

#### Scenario: OpenSpec CLI available
- **WHEN** `openspec --version` is run as the `dev` user
- **THEN** it prints a version string without error
