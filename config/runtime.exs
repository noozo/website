import Config

########################## DEFAULTS AND COMMON CONFIG ##########################
database_url = System.fetch_env!("APP_DATABASE_URL")
base_url = System.get_env("APP_BASE_URL", "pedroassuncao.com")
http_port = System.get_env("APP_HTTP_PORT", "80")
https_port = System.get_env("APP_HTTPS_PORT", "443")

########################## ENV SPECIFIC CONFIG ##########################
case config_env() do
  ########################## DEV ##########################
  :dev ->
    config :noozo, Noozo.Repo, url: database_url

  ########################## TEST ##########################
  :test ->
    :ok

  ########################## PRODUCTION ##########################
  :prod ->
    secret_key_base = System.fetch_env!("APP_SECRET_KEY_BASE")

    config :noozo, Noozo.Repo,
      # ssl: true,
      url: database_url,
      pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

    config :noozo,
      https_redirect_url: "#{base_url}:#{https_port}"

    config :noozo, NoozoWeb.Endpoint,
      http: [:inet6, port: http_port],
      https: [port: https_port],
      secret_key_base: secret_key_base,
      force_ssl: [hsts: true],
      # This is critical for ensuring web-sockets properly authorize.
      url: [host: "#{base_url}", port: https_port]
end
