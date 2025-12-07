defmodule FireStarter.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      listeners: [Phoenix.CodeReloader],
      dialyzer: [
        plt_file: {:no_warn, "plts/fire_starter.plt"},
        plt_add_apps: [:ex_unit, :mix]
      ],
      releases: [
        fire_starter_web: [
          applications: [fire_starter: :permanent, fire_starter_web: :permanent]
        ]
      ],

      # Docs
      name: "FireStarter",
      source_url: "https://github.com/nicholasjhenry/fire-starter-umbrella",
      docs: &docs/0
    ]
  end

  def cli do
    [
      preferred_envs: [
        # Set :dialyzer to run in the same env as :precommit
        dialyzer: :test,
        precommit: :test,
        "test.watch": :test
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp deps do
    [
      # Required to run "mix format" on ~H/.heex files from the umbrella root
      {:phoenix_live_view, ">= 0.0.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"],
      precommit: [
        "compile --warning-as-errors",
        "credo --strict",
        "dialyzer",
        "deps.unlock --unused",
        "format",
        "test"
      ],
      docs: [
        "docs --formatter html --warnings-as-errors",
        "cmd mix docs --formatter html --warnings-as-errors"
      ],
      "docs.open": &open_docs/1,
      "usage_rules.update": [
        # --all - Gather usage rules from all dependencies that have them (includes both main rules and all sub-rules)
        "usage_rules.sync ./AGENTS.md --all --inline usage_rules:all --link-to-folder deps"
      ]
    ]
  end

  defp open_docs(_) do
    System.cmd("open", ["doc/index.html"])
  end

  defp docs do
    [
      # NOTE: Resolves "warning: index.html redirects to README.html, which does not exist".
      main: "readme",
      api_reference: false,
      extras: [
        "README.md",
        "guides/style_guide/style_guide.md",
        "guides/style_guide/code.md",
        "guides/style_guide/phoenix.md",
        "guides/style_guide/ecto.md",
        "guides/style_guide/otp.md",
        "guides/style_guide/architecture.md",
        "guides/style_guide/testing.md",
        "guides/style_guide/documentation.md",
        "guides/style_guide/resources.md",
        "guides/ops/fly_io.md",
        "guides/ops/conductor.md"
      ],
      groups_for_extras: [
        "Style Guide": Path.wildcard("guides/style_guide/*.md"),
        Operations: Path.wildcard("guides/ops/*.md")
      ],
      ignore_apps: apps()
    ]
  end

  defp apps, do: File.ls!("./apps") |> Enum.map(&String.to_atom/1)
end
