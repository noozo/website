defmodule NoozoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :noozo
  use SiteEncrypt.Phoenix

  plug Plug.SSL, exclude: [], host: Application.fetch_env!(:noozo, :https_redirect_url)

  @session_options [
    store: :cookie,
    key: "_noozo_key",
    signing_salt: "CfRkHouB"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  socket "/socket", NoozoWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :noozo,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  plug :bump_metric

  plug NoozoWeb.Router

  defp bump_metric(conn, _opts) do
    register_before_send(conn, fn conn ->
      if conn.status == 200 do
        post = Map.get(conn.assigns, :post)
        path = "/" <> Enum.join(conn.path_info, "/")
        Noozo.Analytics.bump(path, post)
      end

      conn
    end)
  end

  @impl Phoenix.Endpoint
  def init(_key, config) do
    # this will merge key, cert, and chain into `:https` configuration from config.exs
    {:ok, SiteEncrypt.Phoenix.configure_https(config)}

    # to completely configure https from `init/2`, invoke:
    #   SiteEncrypt.Phoenix.configure_https(config, port: 4001, ...)
  end

  @impl SiteEncrypt
  def certification do
    SiteEncrypt.configure(
      # Note that native client is very immature. If you want a more stable behaviour, you can
      # provide `:certbot` instead. Note that in this case certbot needs to be installed on the
      # host machine.
      client: :native,
      # mode: :manual,
      domains: [
        "pedroassuncao.com",
        "www.pedroassuncao.com",
        "cv.pedroassuncao.com",
        "resume.pedroassuncao.com"
      ],
      emails: ["pedro@pedroassuncao.com"],
      db_folder: System.get_env("SITE_ENCRYPT_DB", "/tmp/site_encrypt_db"),

      # set OS env var CERT_MODE to "staging" or "production" on staging/production hosts
      directory_url:
        case System.get_env("CERT_MODE", "local") do
          "local" -> {:internal, port: 4002}
          "staging" -> "https://acme-staging-v02.api.letsencrypt.org/directory"
          "production" -> "https://acme-v02.api.letsencrypt.org/directory"
        end
    )
  end
end
