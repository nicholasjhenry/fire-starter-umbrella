# Project Conventions

**Applies to**: Elixir / Phoenix / Ecto projects using this speckit configuration
**Constitution Version**: 2.0.0
**Last Updated**: 2026-03-06

> This file documents project-specific coding conventions, framework
> patterns, macros, type aliases, and tooling commands. It is the
> authoritative reference for *how* the team implements the principles
> defined in `constitution.md`. Changes to this file follow PATCH-level
> governance unless they alter principle enforcement.

---

## Table of Contents

- [Skills Reference](#skills-reference)
- [Context Modules](#context-modules)
- [Record (Schema) Modules](#record-schema-modules)
- [Typespecs & Documentation](#typespecs--documentation)
- [Authorization](#authorization)
- [Routing](#routing)
- [HTTP Clients](#http-clients)
- [Seed Data](#seed-data)
- [Pre-Commit Tooling](#pre-commit-tooling)
- [Research Tooling](#research-tooling)

---

## Skills Reference

**Supports principle**: I. Skill-Driven Development

Before writing implementation code, invoke the relevant skill for the
domain you are working in. The table below lists the canonical skills
for this project.

| Skill | When to Invoke |
|-------|---------------|
| `elixir-core` | All Elixir code (pattern matching, functions, data structures) |
| `elixir-otp` | GenServers, Supervisors, and concurrent systems |
| `phoenix-contexts` | Context modules and business logic |
| `ecto` | Schemas, changesets, and queries |
| `phoenix-liveview` | LiveView modules and real-time features |
| `phoenix-html` | Templates, components, and forms |
| `elixir-testing` | ExUnit tests and test helpers |
| `elixir-typespec` | Type specifications and typedocs |
| `task-based-ui` | Task-oriented user interface patterns |
| `test-heuristics` | Test design and coverage heuristics |

Use the Skill tool or `/help` command to discover additional
project-scoped and user-scoped skills at runtime.

---

## Context Modules

**Supports principles**: I. Skill-Driven Development, III. Explicit Over Implicit

Substitute `MyApp` for the current applications root namespace.

- Context modules MUST use the `use MyApp, :context` macro.
- Action functions in contexts MUST have an `@spec` with `Attrs.t()` for attribute parameters.
  - NEVER use bare `map()` as the type for attribute parameters.
- Action functions MUST NOT have `@doc` documentation strings.
  Remove any existing module-level docs on action functions.

```elixir
# ✅ Correct
defmodule MyApp.Snippets do
  use MyApp, :context

  @spec create_snippet(Accounts.Scope.t(), Attrs.t()) ::
          {:ok, Snippet.t()} | {:error, Ecto.Changeset.t()}
  def create_snippet(%Accounts.Scope{} = scope, attrs) do
    # ...
  end
end

# ❌ Wrong — bare map(), missing macro, has @doc
defmodule MyApp.Snippets do
  @doc "Creates a snippet."
  @spec create_snippet(Accounts.Scope.t(), map()) ::
          {:ok, Snippet.t()} | {:error, Ecto.Changeset.t()}
  def create_snippet(%Accounts.Scope{} = scope, attrs) do
    # ...
  end
end
```

---

## Record (Schema) Modules

**Supports principles**: I. Skill-Driven Development, III. Explicit Over Implicit

- Record modules MUST use the `use MyApp, :record` macro.
- All public functions in record modules MUST have `@doc false`.
- Use `Snippet.id()` (or the equivalent `<Record>.id()`) for record ID types.
  - NEVER use `Ecto.UUID.t()` or `integer()` directly as the ID type.

```elixir
# ✅ Correct
defmodule MyApp.Snippets.Snippet do
  use MyApp, :record

  @doc false
  def changeset(%__MODULE__{} = snippet, attrs) do
    # ...
  end
end
```

---

## Typespecs & Documentation

**Supports principles**: III. Explicit Over Implicit, I. Skill-Driven Development

- Provide `@type t :: %__MODULE__{}` with all fields and associations
  enumerated for every public Ecto schema.
- Provide `@typedoc` for every public context module and Ecto schema
  using the mandated template that enumerates fields and associations.
- Provide `@spec` for every public function in context modules.
- Invoke the `elixir-typespec` skill before writing or modifying
  typespecs to ensure compliance with project patterns.

---

## Authorization

**Supports principles**: V. Security & Privacy, IV. Fail Fast Fail Loud

- Use `Accounts.Scope` for authorization throughout the application.
- Pass `current_scope` to all context functions that require
  authorization.
- Templates and LiveViews MUST access the current user exclusively
  through `@current_scope.user` — never through a separate assign or
  a direct database lookup in the template.

---

## Routing

**Supports principles**: V. Security & Privacy, III. Explicit Over Implicit

- Follow Phoenix `phx.gen.auth` routing guidance: place routes inside
  the correct pipeline and `live_session`.
- Explain scope choices (`:require_authenticated_user`,
  `:redirect_if_user_is_authenticated`, etc.) in every pull request
  description when adding or modifying routes.

---

## HTTP Clients

**Supports principle**: III. Explicit Over Implicit

- Prefer the bundled `Req` client for all outbound HTTP calls.
- Adding an alternative HTTP client requires:
  1. Explicit maintainer approval.
  2. Configuration documentation in the project README.
  3. A note in the feature plan explaining why `Req` is insufficient.

---

## Seed Data

**Supports principle**: IV. Fail Fast Fail Loud (reproducibility)

- Extend `priv/repo/seeds.exs` (or dedicated seed modules) with
  representative demo data for each new feature.
- Seed data MUST be sufficient for manual verification of the feature
  in a development environment.
- Seed modules MUST be idempotent — running seeds twice produces no
  errors and no duplicate records.

---

## Pre-Commit Tooling

**Supports principle**: Pre-Commit Validation (Engineering Standards)

The pre-commit validation command for this project is:

```bash
mise exec -- mix precommit
```

This runs, in order:

1. `mise exec -- mix format --check-formatted` — code formatting
2. `mise exec -- mix credo --strict` — static analysis / linting
3. `mise exec -- mix test` — full test suite
4. `mise exec -- mix dialyzer` — type checking

All four checks MUST pass before requesting review.

---

## Research Tooling

**Supports principle**: Delivery Workflow — Research Phase

- Use `mise exec -- mix usage_rules.docs` to consult up-to-date documentation
  references before committing to an implementation approach.
- Exercise new functionality through the shared `web` CLI profile
  to capture end-to-end behaviour in a realistic environment.

---

## Changelog

| Date | Summary |
|------|---------|
| 2026-03-06 | Initial extraction from constitution v1.0.0; conventions documented as standalone file |
