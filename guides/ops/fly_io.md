# Provisioning Fly.io

Provisioning [Fly.io](https://fly.io/) with [Managed Postgres](https://fly.io/docs/mpg/).

## Verify Locally

```sh
mise run release:server
```

## Provision Managed Postgres

```sh
fly auth login # if required
fly mpg create --name fire-starter-staging-db --plan basic --region iad --org personal
```

Output:

```
Managed Postgres cluster created successfully!
  ID: [CLUSTER_ID]
  Name: [NAME]
  Organization: personal
  Region: iad
  Plan: basic
  Disk: 10GB
  PostGIS: false
  Connection string: postgresql://fly-user:[PASSWORD]@pgbouncer.[CLUSTER_ID].flympg.net/fly-db
```

## Provision Application

Create an app:

```sh
fly apps create fire-starter-staging-web --org personal
mix compile # ensure output does not get polluted with compile messages
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret) --stage --config apps/fire_starter_web/fly.toml
```

Attach the database PgBouncer connection:

```sh
fly mpg list # get cluster ID
fly mpg attach [CLUSTER_ID] --app fire-starter-staging-web --variable-name DATABASE_URL # variaible name is the default
```

Output:

```
Postgres cluster [CLUSTER_ID] is being attached to fire-starter-staging-web
The following secret was added to fire-starter-staging-web:
  DATABASE_URL=postgresql://fly-user:[PASSWORD]@pgbouncer.[CLUSTER_ID].flympg.net/fly-db
```

Set the release `DATABASE_URL` (migrations do not work with PgBouncer, see `config :fire_starter, FireStarter.Repo` in [runtime config](https://github.com/nicholasjhenry/fire-starter-umbrella/blob/develop/config/runtime.exs)):

```sh
fly secrets set DATABASE_RELEASE_URL=postgresql://fly-user:[PASSWORD]@direct.[CLUSTER_ID].flympg.net/fly-db --stage --config apps/fire_starter_web/fly.toml
```

## Build and Verify Deployment

Verify the build:

```sh
fly deploy --build-only  --config apps/fire_starter_web/fly.toml
```

Deploy:

```
# Do not provision spare machines that increases app availability; reduce cost for testing
fly deploy --ha false --config apps/fire_starter_web/fly.toml
```
