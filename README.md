# 🔥 FireStarter

<!-- fire_starter:start -->
---

A starter application template for a Phoenix Umbella project. What do you get?

### 📦 Installed and configured packages

- [Credo](https://hexdocs.pm/credo)
- [Dialzyer](https://hexdocs.pm/dialyxir)
- [ExDoc](https://hexdocs.pm/ex_doc)
- [EctoErd](https://hexdocs.pm/ecto_erd)
- [Igniter](https://hexdocs.pm/igniter)

### 🤖 Agentic Coding

- [Conductor](https://conductor.build/)
- `CLAUDE.md`
- [Tidewave](https://tidewave.ai/)
- [UsageRules](https://hexdocs.pm/usage_rules)

### ✏️ Style Guide and Documentation

- [Style Guide](guides/style_guide/style_guide.md) ([docs](style_guide.html))
- Documentation deployed to [GitHub Pages](https://nicholasjhenry.github.io/fire-starter-umbrella/)

### 🚀 CI and Deployment

- [GitHub CI Action](.github/workflows/ci.yml)
- [Fly.io Configuration](apps/fire_starter_web/fly.toml)

🚧 Remove the above documentation when using for your own application.

---
<!-- fire_starter:end -->

## Applications

| Application                                                                            | Description                |
| -------------------------------------------------------------------------------------- | -------------------------- |
| [FireStarter](apps/fire_starter/lib/fire_starter.ex) ([docs](fire_starter/index.html)) | Business Application Logic |

## Setup

Prerequistes:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [FlyCTL](https://fly.io/docs/flyctl/install/)
- [Mise-en-place](https://mise.jdx.dev/)

Execute the following:

```sh
cp .env.template .env
# No configuration required
script/setup
```

## Documentation

```sh
mix docs
mix docs.open
```

## Provisioning

See guide: [Provisioning Fly.io](guides/ops/fly_io.md) ([docs](fly_io.html))

## Deployment

Deploy to [Fly.io](https://fly.io/):

```sh
fly auth login # if not authenticated
fly deploy --config apps/fire_starter_web/fly.toml
```
