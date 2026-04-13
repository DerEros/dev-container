## Context

The dev container image installs developer tools as part of the Docker build. Global npm packages are already installed via a single `npm install -g` line in the Dockerfile (currently installing `@angular/cli` and `@anthropic-ai/claude-code`). The `openspec` CLI is distributed as the npm package `@fission-ai/openspec`.

## Goals / Non-Goals

**Goals:**
- `openspec` is available on PATH inside the container for the `dev` user without any post-start setup

**Non-Goals:**
- Pinning to a specific version (latest at build time is fine)
- Configuring openspec project defaults (that lives in `openspec/config.yaml`)

## Decisions

### Add `@fission-ai/openspec` to the existing `npm install -g` line

The Dockerfile already has a global npm install step:
```
RUN npm install -g @angular/cli @anthropic-ai/claude-code
```

Adding `@fission-ai/openspec` to this line is the simplest approach — same pattern, no new layer, no new mechanism.

**Alternatives considered:**
- Separate `RUN npm install -g @fission-ai/openspec` layer: adds a layer with no benefit; rejected.
- Install via curl/binary release: unnecessary complexity given it's an npm package; rejected.

## Risks / Trade-offs

- **Build-time version drift**: Installing `latest` means the image picks up whatever version is current at build time. → Acceptable for a dev tooling image; pin if stability becomes a concern.

## Migration Plan

Rebuild the container image. No data migration or rollback concern — this is purely additive.
