# Behavior records

Behavior records describe expected and current behavior, regression coverage, and known limits for a component. They are the canonical place for behavior-level invariants. Keep related changes for the same component in one record; do not create a record for each code change.

Before changing behavior, update the relevant record with the proposed expectation. After implementation, update its status, current behavior, test coverage, and remaining limitations. If a behavior has no suitable test seam, state that clearly rather than claiming coverage.

## Record template

```markdown
# <Component>

## <BUG-COMPONENT-001 | FEAT-COMPONENT-001>: <short title>
- Type: Bug | Feature
- Status: Proposed | Current | Limited | Resolved
- Scope: <component and affected users or entry points>
- Observed behavior / Reproduction: <for bugs>
- Goal / Acceptance criteria: <for features>
- Expected behavior and invariants: <what must hold>
- Enforcement boundary: <source or configuration boundary>
- Current behavior: <what the repository currently does>
- Regression coverage: <tests or explicit lack of automated coverage>
- Known limitations: <remaining constraints>
```

Use a stable identifier and keep it when the record is updated. These records describe the current state; they are not release notes. Keep architecture decisions and cross-component constraints in [`../decisions/`](../decisions/data-boundaries.md).

## Records

- [App behavior](app.md)
