## ADDED Requirements

### Requirement: .NET SDK 10.0 is installed system-wide
The container SHALL have .NET SDK 10.0 (latest LTS) installed via the Microsoft apt feed and available to all users.

#### Scenario: dotnet CLI is available
- **WHEN** any user runs `dotnet --version` inside the container
- **THEN** the command exits successfully and prints a version string starting with `10.`

#### Scenario: C# project compiles
- **WHEN** a user runs `dotnet build` in a valid C# project directory
- **THEN** the build completes successfully without SDK-not-found errors

### Requirement: dotnet global tools are installable by the dev user
The container SHALL allow the `dev` user to install dotnet global tools via `dotnet tool install -g`.

#### Scenario: Global tool install succeeds
- **WHEN** the `dev` user runs `dotnet tool install -g <tool-name>`
- **THEN** the tool is installed and available on the PATH in subsequent shell sessions
