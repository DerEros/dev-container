## Why

The dev container lacks tooling for Godot 4 game development. Adding the Godot engine binary, .NET SDK, and supporting tools enables an agent-in-container / editor-on-host workflow where the container handles code generation, builds, and headless unit tests while the developer runs the Godot editor natively on macOS for manual testing.

## What Changes

- Install .NET SDK 10.0 (LTS) via Microsoft apt feed
- Install Godot 4.6.2 Linux arm64 `.NET` (mono) build at `/usr/local/bin/godot`
- Set `GODOT_BIN=/usr/local/bin/godot` environment variable for gdUnit4Net test runner integration
- Install `csharp-ls` dotnet tool (C# LSP server for Claude Code editor integration)
- Install `gdtoolkit` Python package (GDScript linter and formatter)

## Capabilities

### New Capabilities

- `godot-engine`: Godot 4.6.2 headless binary with C# (.NET 10) support available in the container
- `dotnet-sdk`: .NET SDK 10.0 LTS for C# compilation, NuGet restore, and dotnet tooling
- `gdscript-tooling`: GDScript linting and formatting via gdtoolkit
- `csharp-lsp`: C# language server (`csharp-ls`) for editor/Claude Code integration

### Modified Capabilities

## Impact

- **Dockerfile**: Four new installation layers (root: .NET SDK + Godot binary; dev user: csharp-ls + gdtoolkit)
- **docker-compose.yml**: No changes required — workspace volume mount already shares files with the macOS host
- **No host changes required**: Developer installs Godot 4.6.2 macOS .NET build separately for the editor; container handles only headless operations
- **Per-project (not in Dockerfile)**: gdUnit4Net NuGet package, gdUnit4 Godot plugin, `.runsettings` file
