defmodule Noozo.MixProject do
  use Mix.Project

  def project do
    [
      app: :noozo,
      version: "4.0.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases()
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
      {:phoenix, "~> 1.6.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.2"},
      {:plug_cowboy, "~> 2.1"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:phoenix_live_view, "~> 0.17.6"},
      {:surface, "~> 0.7.0"},
      {:ecto_psql_extras, "~> 0.2"},
      {:telemetry, "~> 0.4.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5.1"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:timex, "~> 3.7"},
      {:curtail, "~> 1.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.2"},
      {:httpoison, "~> 1.7"},
      {:bcrypt_elixir, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:html_sanitize_ex, "~> 1.3"},
      {:pdf_generator, "~> 0.4"},
      {:atomex, "~> 0.2"},
      {:site_encrypt, "~> 0.4"},
      {:decimal, "~> 2.0"},
      {:comeonin, "~> 5.3"},
      {:elixir_feed_parser, "~> 0.0"},
      {:poison, "~> 5.0.0"},
      {:earmark, "~> 1.4"},
      {:money, "~> 1.9"},
      {:nimble_totp, "~> 0.1.0"},
      {:eqrcode, "~> 0.1.7"},

      # Testing and things
      {:floki, "~> 0.32", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "1.6.1", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev}
    ]
  end

  defp releases() do
    [
      noozo: [
        include_executables_for: [:unix],
        include_erts: true,
        strip_beams: true,
        quiet: false
      ]
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
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs",
        "cmd --cd assets npm install"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
