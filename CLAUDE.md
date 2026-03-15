# FireStarter Umbrella

## Architecture Overview

Elixir/Phoenix umbrella project serving as a production-ready application template. Three child apps with clear separation of concerns:

- **fire_starter** — Core business logic, Ecto schemas, contexts, and OTP supervision
- **fire_starter_web** — Phoenix web layer (controllers, LiveView, components, routing)
- **fs_new** — Project generator built on Igniter for scaffolding new projects

Contexts are the public API boundary. Schemas are private implementation details — never access another context's schemas directly.

## Tech Stack

- **Elixir** 1.19.5 / **OTP** 28.3.1
- **Phoenix** 1.8.1 / **Phoenix LiveView** 1.1.0
- **Ecto** (via ecto_sql 3.13) / **PostgreSQL** 18.0 (Docker)
- **Bandit** 1.5 (HTTP server)
- **Tailwind CSS** 4.1.7 / **esbuild** 0.25.4 / **Heroicons** v2.2.0
- **Swoosh** 1.16 (mailer) / **Req** 0.5 (HTTP client) / **Jason** 1.2 (JSON)
- **Credo** (strict) / **Dialyxir** (static analysis) / **ExDoc** (documentation)
- **Igniter** 0.5 (code generation) / **UsageRules** 1.2.5 / **Tidewave** 0.5

## Project Structure

```
fire_starter_umbrella/
├── apps/
│   ├── fire_starter/           # Core domain (Repo, contexts, schemas)
│   │   ├── lib/fire_starter/   # Business logic organized by context
│   │   ├── priv/repo/          # Migrations and seeds
│   │   └── test/               # DataCase-based tests
│   ├── fire_starter_web/       # Web interface
│   │   ├── lib/fire_starter_web/
│   │   │   ├── controllers/    # Thin HTTP handlers
│   │   │   ├── components/     # Function components (core_components.ex)
│   │   │   ├── router.ex       # Routes with verified routes (~p sigil)
│   │   │   └── endpoint.ex     # Plug pipeline
│   │   └── test/               # ConnCase-based tests
│   └── fs_new/                 # Project generator (Igniter-based)
├── config/                     # Shared configuration (config, dev, test, prod, runtime)
├── guides/style_guide/         # Comprehensive style guides (architecture, code, phoenix, ecto, otp, testing)
└── docker-compose.yaml         # PostgreSQL 18.0 Alpine
```

## Key Conventions

### Module Organization
- `use FireStarter, :record` — includes Ecto.Schema, Ecto.Changeset, Ecto.Query
- `use FireStarter, :context` — includes Ecto.Changeset alias, Repo alias, Ecto.Query
- `use FireStarterWeb, :controller` — includes Phoenix.Controller, Gettext, Plug.Conn, verified routes
- Module order: moduledoc → use/import/alias/require → module attributes → type specs → public functions → private functions
- Module limit: ~300 lines; refactor into submodules beyond that

### Database
- Binary UUIDs for primary keys (`@primary_key {:id, :binary_id, autogenerate: true}`)
- Always include `timestamps()`
- Migrations must be reversible — use `change/0` over `up/0`+`down/0`
- Preload associations to avoid N+1 queries

### Error Handling
- `{:ok, result}` / `{:error, reason}` tuples for expected failures
- `!` suffix functions raise on error — use for unexpected failures
- `with` for sequential operations that may fail
- Let supervisors handle crashes — don't rescue everything

### Testing
- `DataCase` for context/schema tests, `ConnCase` for controller/LiveView tests
- `async: true` for isolated tests
- `describe` blocks to group related tests
- Fixtures for test data (not factories)
- Test public behavior, not implementation

### Phoenix
- Controllers are thin — delegate to contexts immediately
- Pattern match action parameters
- Function components with `attr`/`slot` declarations
- LiveView: initialize all assigns in `mount/3`, use streams for large lists

## Precommit Checks

Run `mise exec -- mix precommit` which executes:
1. `mix compile --warnings-as-errors`
2. `mix credo --strict`
3. `mix dialyzer`
4. `mix deps.unlock --check-unused`
5. `mix format --check-formatted`
6. `mix test`

## Anti-Patterns to Avoid

- **DO NOT** access schemas directly from outside their context
- **DO NOT** put business logic in controllers — delegate to contexts
- **DO NOT** create circular dependencies between contexts
- **DO NOT** use exceptions for expected control flow — use tagged tuples
- **DO NOT** skip changesets for data validation
- **DO NOT** write N+1 queries — use preload
- **DO NOT** block GenServer init with expensive work — use `handle_continue`
- **DO NOT** use unsupervised Tasks — use `Task.Supervisor`
- **DO NOT** abbreviate variable names (`cs`, `pr`) — use descriptive names

## Style Guide Reference

Detailed style guides live in `guides/style_guide/`:
- `architecture.md` — Context boundaries, module dependencies, umbrella patterns
- `code.md` — Naming, module organization, function design, pattern matching, pipelines
- `phoenix.md` — Controllers, components, LiveView, channels, plugs
- `ecto.md` — Schemas, changesets, queries, migrations, repo patterns
- `otp.md` — GenServers, supervisors, tasks, agents, process design
- `testing.md` — Context testing, describe blocks, async, fixtures

<!-- usage-rules-start -->
<!-- usage_rules-start -->
## usage_rules usage
_A config-driven dev tool for Elixir projects to manage AGENTS.md files and agent skills from dependencies_

## Using Usage Rules

Many packages have usage rules, which you should *thoroughly* consult before taking any
action. These usage rules contain guidelines and rules *directly from the package authors*.
They are your best source of knowledge for making decisions.

## Modules & functions in the current app and dependencies

When looking for docs for modules & functions that are dependencies of the current project,
or for Elixir itself, use `mix usage_rules.docs`

```
# Search a whole module
mix usage_rules.docs Enum

# Search a specific function
mix usage_rules.docs Enum.zip

# Search a specific function & arity
mix usage_rules.docs Enum.zip/1
```


## Searching Documentation

You should also consult the documentation of any tools you are using, early and often. The best 
way to accomplish this is to use the `usage_rules.search_docs` mix task. Once you have
found what you are looking for, use the links in the search results to get more detail. For example:

```
# Search docs for all packages in the current application, including Elixir
mix usage_rules.search_docs Enum.zip

# Search docs for specific packages
mix usage_rules.search_docs Req.get -p req

# Search docs for multi-word queries
mix usage_rules.search_docs "making requests" -p req

# Search only in titles (useful for finding specific functions/modules)
mix usage_rules.search_docs "Enum.zip" --query-by title
```


<!-- usage_rules-end -->
<!-- usage-rules-end -->
