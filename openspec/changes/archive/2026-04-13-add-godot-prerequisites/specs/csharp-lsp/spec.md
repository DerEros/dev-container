## ADDED Requirements

### Requirement: csharp-ls is installed and available
The container SHALL have `csharp-ls` installed as a dotnet global tool for the `dev` user, providing a C# LSP server for editor and Claude Code integration.

#### Scenario: csharp-ls binary is on the PATH
- **WHEN** the `dev` user runs `csharp-ls --version`
- **THEN** the command exits successfully and prints a version string

#### Scenario: LSP server starts without error
- **WHEN** the `dev` user launches `csharp-ls` in a directory containing a `.csproj` file
- **THEN** the process starts and begins listening for LSP messages on stdin/stdout without immediately exiting with an error
