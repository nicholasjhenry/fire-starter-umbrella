# Constitution

## Core Principles

Principles are listed in priority order. When principles conflict,
higher-ranked NON-NEGOTIABLE items take precedence. For conflicts
between non-NON-NEGOTIABLE principles, the feature spec's stated
priorities govern.

### I. Skill-Driven Development (NON-NEGOTIABLE)

- Review all available project-scoped and user-scoped agent skills BEFORE starting any task to determine applicability.
- Skills are specialized capability packages containing instructions, scripts, and resources that provide domain-specific expertise.
- Use the Skill tool or `/help` command to discover available skills.
- Invoke relevant skills BEFORE generating implementation code, writing tests, designing UIs, or making architectural decisions.
- Skills encode authoritative patterns and conventions that MUST be followed; deviations require explicit justification in the pull request description.
- Block implementation when applicable skills have not been consulted for the task domain.
- Code generation that violates loaded skill guidance MUST be justified in review with a written rationale.

**Rationale**: Agent skills package ecosystem-specific and project-specific expertise that prevents reinventing solutions, ensures consistency, and reduces review cycles. Skill consultation catches convention violations before they propagate through the codebase. Consolidating skill policy into a single principle eliminates ambiguity about when and how skills apply.

### II. Test-First Development (NON-NEGOTIABLE)

- Write failing automated tests and secure reviewer approval before implementing production code or refactors.
- Follow strict Red-Green-Refactor cycles; commit only the minimal code required to turn the suite green before refactoring.
- Provide integration tests for every cross-boundary pathway (database, external services, UI ↔ context, background jobs).
- A merge gate MUST block merges when required tests are missing or did not fail prior to implementation (see [Merge Gates](#merge-gates)).

**Rationale**: Disciplined TDD prevents regressions, documents behaviour, and keeps the team aligned on intended outcomes before investing in implementation.

### III. Explicit Over Implicit

- Name modules, functions, and variables to reveal intent; avoid convention-based magic or hidden side effects.
- Declare every dependency and contract through function signatures or explicit data structures; never rely on global state.
- Validate configuration at boot with actionable error messages and document all settings in specs, plans, and README updates.
- Record dependency introductions and migrations in feature documents so reviewers can audit the blast radius.

**Rationale**: Explicit contracts make the system predictable, auditable, and safer to evolve under heavy review workloads.

### IV. Fail Fast, Fail Loud

- Validate inputs at entry points (controllers, views, contexts); refuse to proceed when data is invalid or stale.
- Instrument failure paths with structured logging and correlation or trace identifiers for each request or task.
- Wrap external calls in timeouts, retries, and circuit breakers so incidents surface immediately to operators.
- Codify failure expectations in automated tests, covering both success and error scenarios.

**Rationale**: Loud failures protect users from silent data loss, reduce mean time to recovery, and create confidence in continuous delivery.

### V. Security & Privacy

- Sanitize and validate all user-supplied input before processing; never trust client-side data.
- Enforce authentication and authorization checks at every entry point; default to deny.
- Protect against common web vulnerabilities (CSRF, XSS, injection) using framework-provided mechanisms.
- Handle personally identifiable information (PII) with care: minimize collection, encrypt at rest and in transit, and document retention policies.
- Include security-focused test cases (unauthorized access, privilege escalation, malformed input) in every feature's test suite.

**Rationale**: Security and privacy failures erode user trust and carry legal and financial consequences. Treating them as first-class concerns prevents retrofitting defences after incidents occur.

## Engineering Standards

### Pre-Commit Validation (NON-NEGOTIABLE)

- Run the project's configured pre-commit validation suite immediately upon completing any feature implementation, before marking the feature as complete.
- If validation fails, fix all reported issues (formatting, linting, test failures, type errors) before proceeding.
- Do not request review, mark tasks complete, or consider implementation finished until pre-commit validation passes.
- A merge gate MUST block merges when pre-commit validation has not been run or when any checks fail (see [Merge Gates](#merge-gates)).

**Current tooling**: For Elixir/Phoenix projects the validation command is `mix precommit`, which runs formatting, Credo, tests, and Dialyzer. Other stacks MUST define an equivalent command and document it in the project README.

**Rationale**: Automated pre-commit validation catches code quality issues, type errors, and test failures during implementation rather than during review. This reduces review cycles, maintains consistent quality, and ensures broken code never reaches reviewers or the main branch.

### Merge Gates

The following conditions are enforced via CI checks and reviewer approval. A pull request MUST NOT merge until every applicable gate passes.

| Gate | Enforced By | Description |
|------|-------------|-------------|
| **Constitution Check** | CI + Reviewer | PR complies with all NON-NEGOTIABLE principles |
| **Tests Exist & Failed First** | CI + Reviewer | Required tests were authored and demonstrated red before implementation |
| **Pre-Commit Passes** | CI | Project pre-commit validation suite exits cleanly |
| **Skill Compliance** | Reviewer | Generated code follows loaded skill guidance or documents justification |
| **Convention Compliance** | CI + Reviewer | Code follows project conventions (see `conventions.md`) |
| **Security Review** | Reviewer | Auth, input validation, and data handling reviewed for features touching user data or external services |

**Rationale**: Defining merge gates in one place eliminates scattered "block merges when…" language, makes enforcement auditable, and gives CI pipeline authors a single source of truth for required checks.

### Project Conventions

Project-specific coding conventions, framework patterns, macros, type aliases, and tooling commands MUST be documented in a dedicated `conventions.md` file alongside this constitution.

- The conventions file is authoritative for implementation details (e.g., which macros to use, type aliases, routing patterns, seed data practices).
- The conventions file MUST reference which constitution principles each convention supports.
- Conventions may be updated independently of the constitution under PATCH-level governance (no principle change required).
- When skills provide guidance that conflicts with documented conventions, the conventions file governs unless the skill is explicitly updated.

**Rationale**: Separating principles (the "why" and "what") from conventions (the "how") keeps the constitution stable and reusable across projects while giving each project a clear, auditable place for implementation-specific rules.

## Delivery Workflow & Tooling

### Specification Phase

- Feature specs, plans, and task lists MUST enumerate the failing tests to be authored first, including unit and integration coverage.
- Keep configuration, dependency, and data migration steps explicit in planning documents so no implicit work lands in implementation.

### Research Phase

- Researchers MUST consult project documentation tooling (e.g., `mix usage_rules.docs`) and update documentation links before committing to an approach.
- Exercise new functionality through the project's shared CLI profiles or test harnesses to capture end-to-end behaviour and document findings.

### Release Phase

- Sync demo data, documentation, and test fixtures for every release to preserve reproducibility.
- Extend seed data with representative demo records for each feature to enable manual verification.
- Update the project README and any quickstart guides when new configuration or setup steps are introduced.

**Rationale**: Structuring delivery into explicit phases ensures that planning captures all implicit work, research is grounded in current documentation, and releases remain reproducible across environments.

## Governance

### Principle Hierarchy

When principles conflict, resolution follows this order:

1. NON-NEGOTIABLE principles override all others, resolved by their listed rank (I → II → III…).
2. Among non-NON-NEGOTIABLE principles, the feature specification's stated priorities govern.
3. If ambiguity remains, the maintainer reviewing the PR makes the final call and documents the reasoning in the review.

### Amendment Process

- Amendments require a written proposal, maintainer approval, and synchronized updates to all dependent templates before merging.
- Versioning follows semantic rules:
  - **MAJOR**: Principle removals, incompatible governance changes, or structural reorganizations that alter enforcement.
  - **MINOR**: New principles, new sections, or material expansions of existing guidance.
  - **PATCH**: Clarifications, wording improvements, convention-only changes, or typo fixes.
- Compliance is reviewed in every pull request; merges are blocked until all applicable Merge Gates pass.
- Track ratification and amendment metadata in the Changelog below and reference the governing version in commit messages when altering process.

### Changelog

| Version | Date | Type | Summary |
|---------|------|------|---------|
| 2.0.0 | 2026-03-06 | MAJOR | Consolidated skill sections; extracted project conventions; added Merge Gates, Principle Hierarchy, Security & Privacy; restructured Delivery Workflow |
| 1.0.0 | 2026-03-01 | — | Initial ratification |

**Version**: 2.0.0 | **Ratified**: 2026-03-01 | **Last Amended**: 2026-03-06
