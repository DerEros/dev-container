## Requirements

### Requirement: OpenSpec CLI available
The image SHALL include the `openspec` CLI (`@fission-ai/openspec`) installed globally and available on PATH for the `dev` user.

#### Scenario: openspec is on PATH
- **WHEN** `openspec --version` is run as the `dev` user
- **THEN** it prints a version string without error
