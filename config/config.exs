# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :noozo,
  ecto_repos: [Noozo.Repo],
  https_redirect_url: "localhost:4001"

config :noozo, Noozo.Repo, telemetry_prefix: [:noozo, :repo]

# Configures the endpoint
config :noozo, NoozoWeb.Endpoint,
  url: [scheme: "https", host: "localhost", port: 4001],
  http: [port: 80],
  https: [port: 4001],
  force_ssl: [hsts: true],
  # This is critical for ensuring web-sockets properly authorize.
  secret_key_base: "Z6VAOMC4PfLgS9GRR19qdJlyhs1Hod5C6G2+0CXVD9Cxhm062WQ+NHOsS34TLF67",
  render_errors: [view: NoozoWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Noozo.PubSub,
  live_view: [
    signing_salt: "LtCCzqceIpbKLeM6PcY6LXdraWKYuw4Hvw04U+IPisTekpgywjM+rIqefF3cAMrp"
  ],
  check_origin: ["//localhost", "//*.pedroassuncao.com"]

config :noozo,
  uploads_folder: "/tmp/website_uploads"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix,
  json_library: Jason,
  template_engines: [
    leex: Phoenix.LiveView.Engine
  ]

config :ueberauth, Ueberauth,
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"]
       ]}
  ]

config :money,
  default_currency: :EUR

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.15",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.36.0",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

config :tailwind,
  version: "3.0.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
