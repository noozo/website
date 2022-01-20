import Config

# Configure your database
config :noozo, Noozo.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :noozo, NoozoWeb.Endpoint,
  # server: true,
  code_reloader: true,
  http: [port: 4000],
  debug_errors: true,
  check_origin: false,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    npx: [
      "tailwindcss",
      "--input=css/app.scss",
      "--output=../priv/static/assets/app.css",
      "--postcss",
      "--watch",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :noozo, NoozoWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|s?css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/noozo_web/{live,views}/.*(ex)$",
      ~r"lib/noozo_web/templates/.*(eex)$",
      ~r{lib/*/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Run static analysis tool when running tests
config :mix_test_watch,
  clear: true,
  tasks: [
    "format",
    "test",
    "credo --strict",
    "sobelow --verbose --config --skip"
    # "dialyzer" Think about this one
  ]
