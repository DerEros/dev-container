## ADDED Requirements

### Requirement: gdtoolkit is installed and available
The container SHALL have `gdtoolkit` installed via pip (using the pyenv-managed Python 3.12) and expose `gdformat` and `gdlint` on the `dev` user's PATH.

#### Scenario: gdlint is available
- **WHEN** the `dev` user runs `gdlint --version`
- **THEN** the command exits successfully and prints a version string

#### Scenario: gdformat is available
- **WHEN** the `dev` user runs `gdformat --version`
- **THEN** the command exits successfully and prints a version string

#### Scenario: GDScript file can be linted
- **WHEN** the `dev` user runs `gdlint <path-to-.gd-file>` on a valid GDScript file
- **THEN** the command exits with code 0 and prints no errors
