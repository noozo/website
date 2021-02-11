import Config

config :noozo,
  ecto_repos: [Noozo.Repo]

config :noozo, NoozoWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  force_ssl: [hsts: true]

# Do not print debug messages in production
config :logger, level: :info
