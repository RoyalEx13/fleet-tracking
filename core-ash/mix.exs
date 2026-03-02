defmodule FleetTracking.MixProject do
  use Mix.Project

  def project do
    [
      app: :fleet_tracking,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      consolidate_protocols: Mix.env() != :dev
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FleetTracking.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
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
      {:ex_money_sql, "~> 1.0"},
      {:ex_cldr, "~> 2.0"},
      {:simple_sat, "~> 0.1"},
      {:sourceror, "~> 1.8", only: [:dev, :test]},
      {:oban, "~> 2.0"},
      {:open_api_spex, "~> 3.0"},
      {:pbkdf2_elixir, "~> 2.2"},
      {:ash_money, "~> 0.2"},
      {:usage_rules, "~> 1.0", only: [:dev]},
      {:ash_cloak, "~> 0.2"},
      {:cloak, "~> 1.0"},
      {:langchain, github: "brainlid/langchain", branch: "main", override: true},
      {:ash_ai, "~> 0.5"},
      {:ash_paper_trail, "~> 0.5"},
      {:tidewave, "~> 0.5", only: [:dev]},
      {:ash_archival, "~> 2.0"},
      {:ash_events, "~> 0.6"},
      {:ash_state_machine, "~> 0.2"},
      {:ash_oban, "~> 0.7"},
      {:ash_admin, "~> 0.14"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_authentication, "~> 4.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_json_api, "~> 1.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:phoenix, "~> 1.8.4"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:igniter, "~> 0.7", only: [:dev, :test]},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild fleet_tracking"],
      "assets.deploy": [
        "esbuild fleet_tracking --minify",
        "phx.digest"
      ]
    ]
  end
end
