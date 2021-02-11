defmodule Noozo.MixProject do
  use Mix.Project

  def project do
    [
      app: :noozo,
      version: "3.5.0",
      elixir: "~> 1.10",
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
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.3"},
      {:postgrex, "~> 0.15"},
      {:phoenix_html, "~> 2.11"},
      {:telemetry_metrics, "~>0.0"},
      {:telemetry_poller, "~> 0.0"},
      {:phoenix_live_view, "~> 0.15"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:timex, "~> 3.5"},
      {:curtail, "~> 1.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.2"},
      {:bcrypt_elixir, "~> 2.0"},
      {:scrivener_ecto, "~> 2.0"},
      {:html_sanitize_ex, "~> 1.3"},
      {:pdf_generator, "~> 0.4"},
      {:atomex, "~> 0.2"},
      {:site_encrypt, "~> 0.4"},
      {:decimal, "~> 2.0"},
      {:comeonin, "~> 5.3"},
      {:elixir_feed_parser, "~> 0.0"},
      {:httpoison, "~> 1.6"},
      {:earmark, "~> 1.4"},
      {:money, "~> 1.4"},

      # Testing and things
      {:floki, "~> 0.29", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: false}
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
