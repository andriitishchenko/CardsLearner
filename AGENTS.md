# Agent instructions

## Task branches and commits

- Before editing, check the current Git branch. If it is `master`, create a new task-specific branch with the `codex/` prefix. If it is any other branch, continue working on that branch without creating or switching branches.
- When the task is complete, review the diff and automatically commit all changes made for that task. Use a concise commit message that describes the work.
- Commit only changes belonging to the current task. Preserve pre-existing or unrelated user changes, and never commit secrets, credentials, or user data.
- Do not merge changes into `master` unless the user explicitly asks for the merge. The user handles merges by default.

## Before making changes

- Read this file, `README.md`, relevant documentation, the source and configuration related to the task, and `git status` before editing.
- Treat source code and project configuration as authoritative when documentation conflicts with them. Investigate the discrepancy and update the documentation in the same task when needed.
- Confirm project facts from the current repository. Do not invent components, behavior, dependencies, commands, tests, or constraints.
- Check whether a fact already has a canonical documentation location before adding it. Keep each fact in one canonical place and link to it elsewhere.
- Never record secrets, tokens, keys, or user data.

## Behavior changes and regression coverage

- Before fixing a bug or implementing a feature, record its expected behavior in the relevant component's behavior record. Group related bugs and features in one component record instead of creating a record for every change.
- For behavior that can be covered by tests, add or update regression tests using the repository's existing XCTest infrastructure.
- After the work, update the behavior record's status, regression coverage, and known limitations so it describes the current project state.

## Keeping documentation current

- After significant changes to behavior, architecture, components, commands, dependencies, or constraints, synchronize the affected documentation in the same task.
- Keep stable architectural decisions and constraints in `DOCS/decisions/`, separately from behavior records.
- Document current state, not a change log. Do not add changed-file lists, dates, temporary paths, routine build output, or details recoverable from Git.
- After editing, check that documentation matches the code and configuration, verify links between documents, and review the complete diff.
- Keep all project documentation in English.

See [README.md](README.md) for the project overview and documentation index, [DOCS/architecture.md](DOCS/architecture.md) for component structure, and [DOCS/behavior/README.md](DOCS/behavior/README.md) for behavior record requirements.
