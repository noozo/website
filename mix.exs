defmodule Noozo.MixProject do
  use Mix.Project

  def project do
    [
      app: :noozo,
      version: "5.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Noozo.Application, []},
      extra_applications: [
        :logger,
        :ueberauth,
        :ueberauth_identity,
        :runtime_tools,
        :timex,
        :scrivener_ecto
      ]
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
      {:phoenix, "~> 1.8"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_pubsub, "~> 2.1.1"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_view, ">= 2.0.0"},
      {:ecto_psql_extras, "~> 0.7.10"},
      {:telemetry, "~> 1.1.0"},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0.0"},
      {:gettext, "~> 0.20.0"},
      {:jason, "~> 1.4.0"},
      {:timex, "~> 3.7.9"},
      {:curtail, "~> 2.0.0"},
      {:ueberauth, "~> 0.10.3"},
      {:ueberauth_identity, "~> 0.4.2"},
      {:httpoison, "~> 1.8.2"},
      {:bcrypt_elixir, "~> 3.0.1"},
      {:scrivener_ecto, "~> 2.7.0"},
      {:html_sanitize_ex, "~> 1.4.2"},
      {:pdf_generator, "~> 0.6.2"},
      {:atomex, "~> 0.5.1"},
      {:site_encrypt, "~> 0.4.2"},
      {:decimal, "~> 2.0.0"},
      {:comeonin, "~> 5.3.3"},
      {:elixir_feed_parser, "~> 2.1.0"},
      {:poison, "~> 5.0.0"},
      {:earmark, "~> 1.4.34"},
      {:money, "~> 1.12"},
      {:nimble_totp, "~> 0.2.0"},
      {:eqrcode, "~> 0.1.10"},
      {:esbuild, "~> 0.5.0"},
      # AI powered development
      {:tidewave, "~> 0.5", only: :dev},
      {:phoenix_html_helpers, "~> 1.0"},

      # Testing and things
      {:floki, "~> 0.34.0", only: :test},
      {:phoenix_live_reload, "~> 1.6.1", only: :dev},
      {:mix_test_watch, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.2.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.2", only: :test},
      {:dialyxir, "~> 1.2.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.11.1", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ],
      precommit: [
        "compile --warning-as-errors",
        "deps.unlock --unused",
        "format",
        "credo --strict"
      ]
    ]
  end
end
