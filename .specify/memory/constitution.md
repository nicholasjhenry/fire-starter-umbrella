<!--
Sync Impact Report
Version change: 1.2.0 -> 1.3.0
Modified principles: None
Added sections: Review Available Skills (new NON-NEGOTIABLE principle under Core Principles)
Removed sections: None
Templates requiring updates:
- ✅ .specify/templates/plan-template.md (already has skill-driven implementation in Constitution Check)
- ✅ .specify/templates/spec-template.md (no changes needed)
- ✅ .specify/templates/tasks-template.md (no changes needed)
- ✅ CLAUDE.md (already contains Review Available Skills guidance - this amendment formalizes it)
Follow-up TODOs: None - all templates aligned with new principle
-->

# ReviewRoom Constitution

## Core Principles

### Review Available Skills (NON-NEGOTIABLE)
- Review all available project-scoped and user-scoped agent skills BEFORE starting any task to determine applicability.
- Skills are specialized capability packages containing instructions, scripts, and resources that provide domain-specific expertise.
- Use the Skill tool or `/help` command to discover available skills; common skills include `elixir-core`, `phoenix-liveview`, `ecto`, `elixir-testing`, `task-based-ui`, and `test-heuristics`.
- Invoke relevant skills BEFORE generating implementation code, writing tests, designing UIs, or making architectural decisions.
- Skills encode authoritative patterns and conventions that MUST be followed; deviations require explicit justification.
- Block implementation when applicable skills have not been consulted for the task domain.

**Rationale**: Agent skills package ecosystem-specific and project-specific expertise that prevents reinventing solutions, ensures consistency, and reduces review cycles. Skill consultation catches convention violations before they propagate through the codebase.

### Test-First Development (NON-NEGOTIABLE)
- Write failing automated tests and secure reviewer approval before implementing production code or refactors.
- Follow strict Red-Green-Refactor cycles; commit only the minimal code required to turn the suite green before refactoring.
- Provide integration tests for every cross-boundary pathway (database, external services, LiveView <-> context, background jobs).
- Block merges when required tests are missing or do not fail prior to implementation.

**Rationale**: Disciplined TDD prevents regressions, documents behaviour, and keeps the team aligned on intended outcomes before investing in implementation.

### Explicit Over Implicit
- Name modules, functions, and assigns to reveal intent; avoid convention-based magic or hidden side effects.
- Declare every dependency and contract through function signatures or explicit data structures; never rely on global state or the process dictionary.
- Validate configuration at boot with actionable error messages and document all settings in specs, plans, and README updates.
- Record dependency introductions and migrations in feature documents so reviewers can audit the blast radius.

**Rationale**: Explicit contracts make the system predictable, auditable, and safer to evolve under heavy review workloads.

### Fail Fast, Fail Loud
- Validate inputs at controllers, LiveViews, and contexts; refuse to proceed when data is invalid or stale.
- Instrument failure paths with structured logging and correlation or trace identifiers for each request or task.
- Wrap external calls in timeouts, retries, and circuit breakers so incidents surface immediately to operators.
- Codify failure expectations in automated tests, covering both success and error scenarios.

**Rationale**: Loud failures protect users from silent data loss, reduce mean time to recovery, and create confidence in continuous delivery.

## Engineering Standards

### Skill-Driven Implementation (NON-NEGOTIABLE)
- Invoke the appropriate language and framework skills BEFORE generating any implementation code.
- For Elixir/Phoenix projects, MUST invoke these skills before implementation:
  - `elixir-core` for all Elixir code (pattern matching, functions, data structures)
  - `elixir-otp` for GenServers, Supervisors, and concurrent systems
  - `phoenix-contexts` for context modules and business logic
  - `ecto` for schemas, changesets, and queries
  - `phoenix-liveview` for LiveView modules and real-time features
  - `phoenix-html` for templates and forms
  - `elixir-testing` for ExUnit tests
  - `elixir-typespec` for type specifications
- Skills provide authoritative patterns, conventions, and best practices that MUST be followed.
- Code generation that violates loaded skill guidance requires explicit justification in review.
- Block merges when generated code does not follow skill-mandated conventions (e.g., missing `use ReviewRoom, :context`, incorrect typespec usage, missing `@doc false` on record functions).

**Rationale**: Skills encode project-specific and ecosystem-specific conventions that prevent style drift, reduce review cycles, and ensure consistency across the codebase. Automated skill consultation eliminates "reinventing the wheel" and catches violations before they reach reviewers.

### Pre-Commit Validation (NON-NEGOTIABLE)
- Run `mix precommit` immediately upon completing any feature implementation, before marking the feature as complete.
- If `mix precommit` fails, fix all reported issues (formatting, credo warnings, test failures, Dialyzer errors) before proceeding.
- Do not request review, mark tasks complete, or consider implementation finished until `mix precommit` passes successfully.
- Block merges when `mix precommit` has not been run or when any precommit checks fail.

**Rationale**: Automated precommit validation catches code quality issues, type errors, and test failures immediately during implementation rather than during review. This reduces review cycles, maintains consistent code quality, and ensures that broken code never reaches reviewers or the main branch.

### Phoenix & Ecto Conventions
- Follow Phoenix phx.gen.auth routing guidance: place routes inside the correct pipeline and live_session, and explain scope choices in every review.
- Use Accounts.Scope for authorization and pass current_scope to context functions; templates must access @current_scope.user exclusively.
- Context modules MUST use `use ReviewRoom, :context` macro.
- Record (schema) modules MUST use `use ReviewRoom, :record` macro.
- Action functions in contexts MUST have `@spec` with `Attrs.t()` for parameters (NEVER `map()`).
- Action functions MUST NOT have `@doc` documentation (remove all module-level docs).
- Record functions MUST have `@doc false`.
- Use `Snippet.id()` for record IDs (NEVER `Ecto.UUID.t()` or `integer()` directly).
- Prefer the bundled Req client for HTTP calls; adding alternatives requires explicit approval and configuration documentation.
- Provide typespecs and typedocs for every public context module and Ecto schema using the mandated template that enumerates fields and associations.
- Extend priv/repo/seeds.exs (or dedicated seed modules) with representative demo data for each feature to enable manual verification.

## Delivery Workflow & Tooling

- Feature specs, plans, and task lists must enumerate the failing tests to be authored first, including unit and integration coverage.
- Researchers must consult `mix usage_rules.docs` and update documentation links before committing to an approach.
- Exercise new functionality through the shared `web` CLI profiles to capture end-to-end behaviour and document findings.
- Keep configuration, dependency, and data migration steps explicit in planning documents so no implicit work lands in implementation.
- Sync demo data, documentation, and test fixtures for every release to preserve reproducibility.

## Governance

- Amendments require a written proposal, maintainer approval, and synchronized updates to all dependent templates before merging.
- Versioning follows semantic rules: MAJOR for principle removals or incompatible governance, MINOR for new principles or material expansions, PATCH for clarifications.
- Compliance is reviewed in every pull request; merges are blocked until the Constitution Check passes and mandated tests exist and fail prior to implementation.
- Track ratification and amendment metadata in this document and reference the governing version in commit messages when altering process.

**Version**: 1.3.0 | **Ratified**: 2025-10-30 | **Last Amended**: 2025-11-25
