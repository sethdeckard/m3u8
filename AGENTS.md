# AGENTS.md

## Development Workflow

- Git workflow: GitHub flow
- Small (but logical) commits that can each be deployed independently
- Each commit must not break CI
- Prefer incremental changes over large feature branches

### Commit Messages

**Subject:** Max 50 chars, capitalized, no period, imperative mood ("Add" not "Added")

**Body:** Wrap at 72 chars, explain what/why not how, blank line after subject

**Leading verbs:** Add, Remove, Fix, Upgrade, Refactor, Reformat, Document, Reword

## Development Standards

- README updated with API changes
- **Tests must cover all behavior** - check with `coverage/index.html` after running specs
- RuboCop enforces 80-char line limit and other style

## Deployment

- Kicking off PR: `ghprcw`
- Never deploy anything
