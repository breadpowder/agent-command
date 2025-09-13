# Repository Guidelines

## Project Structure & Module Organization
- `commands/`: Command specs in Markdown (one file per command). Use `sdlc_<verb>_<scope>.md` (e.g., `sdlc_implement_feature.md`).
- `README.md`: Primary user guide, workflows, and examples (source of truth).
- `docs/`: Supporting reference material or diagrams (optional).
- `examples/`: Small, non-sensitive example snippets or workspace snapshots.

## Build, Test, and Development Commands
- Build: none required (documentation-first repository).
- Preview Markdown: use your editor’s preview; optional: `glow README.md`.
- Lint Markdown (optional): `npx markdownlint-cli "**/*.md"` if available.
- Quick search: `rg -n 'sdlc_' commands/` to audit command docs.

## Coding Style & Naming Conventions
- Markdown: ATX headings (`#`, `##`), sentence case headings, and fenced code blocks with language hints (`bash`, `text`).
- Lists: hyphen-prefixed (`- `), keep bullets concise; wrap lines around ~100 chars.
- Filenames: snake_case; commands as `sdlc_<verb>_<topic>.md`.
- Examples: use the standard flags consistently: `--name`, `--source`, `--type`, `--id`.

## Testing Guidelines
- Validate examples in `README.md` and `commands/` against the AgentDK CLI (where installed) and ensure they are safe, idempotent, and copy-pasteable.
- Keep outputs and workspace trees aligned with README’s “Workspace Organization”.
- Prefer non-destructive flows; if showing rollback, demonstrate `git revert` rather than history rewrites.

## Commit & Pull Request Guidelines
- Commit messages for workflow changes: `sdlc: <action> <name> - <summary>` (e.g., `sdlc: plan feature user-auth - architecture complete`).
- Documentation-only changes: `docs: <area> - <summary>`.
- Never force-push or rewrite history; use `git revert` (not `git reset`).
- PRs: clear purpose, linked issues, affected files, before/after snippets or screenshots, and any updates to README “Quick Start” when commands change.

## Security & Configuration Tips
- Do not include secrets, tokens, or internal URLs in docs or examples.
- Clearly mark any destructive commands; prefer safe alternatives or add cautionary notes.

