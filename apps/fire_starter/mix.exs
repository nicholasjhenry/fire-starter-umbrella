defmodule FireStarter.MixProject do
  use Mix.Project

  def project do
    [
      app: :fire_starter,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      # Docs
      name: "FireStarter",
      homepage_url: "../index.html",
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FireStarter.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dns_cluster, "~> 0.2.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:ecto_erd, "~> 0.8.0", only: [:dev]},
      {:ex_doc, "~> 0.38", only: [:dev]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    # process in the root of the umbrella (../../)
    assets_path = "../../doc/fire_starter/assets"

    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run #{__DIR__}/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      docs: ["docs", "docs.gen.erd"],
      "docs.gen.erd": [
        "cmd mkdir -p doc/assets",
        # NOTE: See `./.ecto_erd.exs for configuration`
        "ecto.gen.erd --config-path ../../.ecto_erd.exs --output-path #{assets_path}/ecto_erd.dot",
        "cmd dot -Tpng #{assets_path}/ecto_erd.dot -o #{assets_path}/erd.png"
      ]
    ]
  end

  defp docs do
    [
      # NOTE: Module name
      main: "FireStarter",
      output: "../../doc/fire_starter",
      # logo: "path/to/logo.png",
      extras: [
        # EXAMPLE:
        # "notebooks/case_study_1.livemd",
        # "notebooks/case_study_2.livemd"
      ],
      groups_for_extras: [
        # EXAMPLE:
        # "Case Studies": Path.wildcard("notebooks/*.livemd")
      ],
      assets: %{
        "guides/assets" => "assets"
      },
      api_reference: true,
      groups_for_modules: [
        # EXAMPLE:
        # Accounts: [
        #   ~r"^FireStarter\.Accounts",
        #   ~r"^FireStarter\.Accounts\..*"
        # ],
      ],
      nest_modules_by_prefix: []
    ]
  end
end
