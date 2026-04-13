## Why

The `openspec` CLI is used to manage change proposals and specs for this project, but it must currently be installed manually after spinning up the dev container. Pre-installing it ensures the tool is immediately available to anyone working in the container without extra setup steps.

## What Changes

- The `openspec` CLI is installed in the dev container image alongside other developer tools
- No manual installation step is needed after container startup

## Capabilities

### New Capabilities

- `openspec-cli`: The `openspec` CLI tool installed and available on PATH for the `dev` user

### Modified Capabilities

- `dev-container-image`: Adds `openspec` as a pre-installed tool in the image

## Impact

- `Dockerfile`: New install step for the `openspec` CLI
- `openspec/specs/dev-container-image/spec.md`: New requirement for `openspec` availability
