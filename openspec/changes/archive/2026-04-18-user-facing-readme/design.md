## Context

The project has a `Dockerfile`, `docker-compose.yml`, and `spin.sh` but no documentation. New users (colleagues) need a single reference document to understand what the container offers, how to get it running, and how to tailor it to their preferences.

## Goals / Non-Goals

**Goals:**
- Document the container's purpose and included toolchain
- Explain the full setup flow: clone → build → spin up
- Describe `spin.sh`'s create/resume/attach behaviour
- Cover dotfiles customization (the most common adaptation)
- Call out the arm64 and OrbStack/macOS constraints

**Non-Goals:**
- Document every possible Dockerfile customization (too open-ended)
- Tool-specific usage guides (e.g., how to use kubectl or Terraform)
- CI/CD or remote build workflows

## Decisions

**Single README.md at repo root**
A single file is the standard entry point for any GitHub repo and requires no navigation. Splitting into a `docs/` folder would add friction for what is concise, focused content.

**Bullet list over table for tools inventory**
A table (tool | purpose) is harder to maintain as the image evolves. A flat bulleted list groups tools naturally by category and is easy to extend.

**Describe spin.sh logic explicitly**
The create-or-resume-or-attach behaviour is a genuine feature, not obvious from the script name. A short diagram communicates it more clearly than prose and sets correct expectations.

**Customization section scoped to dotfiles only**
Dockerfile-layer customization is valid but highly individual and risky to document incompletely. Dotfiles (p10k config, zshrc additions, volume mounts) cover the most common need without opening an unbounded topic.

**Platform constraints surfaced in Prerequisites**
The arm64 Godot binary and vfs Docker storage driver are blockers for users on x86 or non-OrbStack setups. Burying these in a footnote risks wasted setup time; they belong in Prerequisites with clear callout blocks.

## Risks / Trade-offs

- **Staleness**: The tools list in the README can drift from the Dockerfile over time. → Mitigate by keeping the list categorical (e.g., "Java via SDKMAN") rather than pinning versions.
- **OrbStack assumption**: Calling out OrbStack specifically may confuse users on Docker Desktop. → Frame it as "tested on OrbStack; other Docker setups may need adjustments" rather than a hard requirement.

## Open Questions

<!-- none -->
