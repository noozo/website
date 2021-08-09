defmodule NoozoWeb.Router do
  use NoozoWeb, :router
  require Ueberauth

  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    # plug :put_secure_browser_headers,
    #   %{
    #     "content-security-policy" =>
    #       """
    #       base-uri
    #       'self';

    #       default-src
    #       'self'
    #       'unsafe-inline'
    #       https://www.google-analytics.com
    #       https://localhost:4001;

    #       script-src
    #       'unsafe-inline'
    #       'unsafe-eval'
    #       https://www.googletagmanager.com
    #       https://www.google-analytics.com/
    #       https://www.google.com/recaptcha/
    #       https://www.gstatic.com/recaptcha/
    #       https://localhost:4001;

    #       style-src
    #       'self'
    #       'unsafe-inline'
    #       'sha256-JplxS3ZsBrP3aZQRQfTgHGXQ3qI60A+11PWJSWLulVA='
    #       https://www.googletagmanager.com
    #       https://fonts.googleapis.com/
    #       https://www.google.com/recaptcha/;

    #       img-src 'unsafe-inline'
    #       https://ssl.gstatic.com/
    #       https://example.com/images/smal-example-logo.png
    #       https://stats.g.doubleclick.net
    #       https://www.google-analytics.com/
    #       https://avatars.githubusercontent.com
    #       https://localhost:4001;

    #       frame-src
    #       https://www.gstatic.com/
    #       https://www.google.com/
    #       https://www.googletagmanager.com/ns.html
    #       https://localhost:4001;

    #       font-src
    #       'self'
    #       https://example.com/fonts/
    #       https://fonts.gstatic.com;

    #       connect-src
    #       www.google-analytics.com
    #       https://www.google-analytics.com
    #       https://stats.g.doubleclick.net
    #       wss://localhost:4001;

    #       object-src
    #       'none';
    #       """
    #       |> String.replace("\r", " ")
    #       |> String.replace("\n", " ")
    #   }
    plug :put_secure_browser_headers
    # , %{
    #   "Permissions-Policy" => "interest-cohort=()"
    # }

    plug NoozoWeb.CurrentUserPlug
    plug NoozoWeb.GoogleAnalyticsPlug
    plug :put_root_layout, {NoozoWeb.LayoutView, :root}
  end

  pipeline :restricted_browser do
    plug :browser
    plug NoozoWeb.EnsureAuthenticatedPlug
    plug :put_root_layout, {NoozoWeb.LayoutView, :admin_root}
  end

  scope "/auth", NoozoWeb do
    pipe_through(:browser)

    get "/logout", AuthController, :logout
    get "/:provider", AuthController, :request
    # get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
  end

  scope "/admin", NoozoWeb.Admin do
    pipe_through :restricted_browser

    live_dashboard "/dashboard", metrics: NoozoWeb.Telemetry

    live "/posts", Post.IndexView
    live "/posts/new", Post.CreateView
    live "/posts/:id/edit", Post.EditView, id: :id

    live "/pages", Page.IndexView
    live "/pages/new", Page.CreateView
    live "/pages/:id/edit", Page.EditView, id: :id

    live "/log", DailyLog.IndexView
    live "/log/:date", DailyLog.EditView, date: :date

    live "/finance", Finance.IndexView

    live "/users", Accounts.IndexView
    live "/users/:id/edit", Accounts.EditView, id: :id
    live "/users/:id/setup_2fa", Accounts.TwoFactorSetupView, id: :id

    scope "/analytics", Analytics do
      live "/", IndexView
    end

    scope "/cvs", Cvs do
      live "/", IndexView
      live "/new", CreateView
      live "/:uuid/edit", EditView, uuid: :uuid
    end

    scope "/gallery", Gallery do
      live "/", IndexView
      live "/new", CreateView
      live "/:uuid/edit", EditView, uuid: :uuid
    end

    live "/", Post.IndexView
  end

  scope "/admin/todo", NoozoWeb.Admin.Todo do
    pipe_through :restricted_browser

    live "/boards/new", Board.CreateView
    live "/boards/:id/edit", Board.EditView, id: :id
    live "/boards/:id", Board.ShowView, id: :id
    live "/labels", Label.IndexView
    live "/", Board.IndexView
  end

  scope "/", NoozoWeb, host: "cv." do
    pipe_through :browser
    get "/", ResumeRedirectController, :redirect
  end

  scope "/", NoozoWeb, host: "resume." do
    pipe_through :browser
    get "/", ResumeRedirectController, :redirect
  end

  scope "/", NoozoWeb do
    pipe_through :browser
    get "/pages/resume", ResumeRedirectController, :redirect
  end

  scope "/", NoozoWeb do
    pipe_through(:browser)

    # Experiments
    scope "/experiments", Experiments do
      scope "/games", Games do
        live("/memory", Memory.MainView)
      end
    end

    live "/gallery", Gallery.IndexView

    live "/posts/:slug", Post.ShowView, slug: :slug
    live "/tag/:tag", Post.IndexView, tag: :tag
    live "/posts", Post.IndexView

    live "/resume/:user_id", Cvs.ShowView, user_id: :user_id

    get "/pages/:slug/pdf", PDFGenerationController, :page
    live "/pages/:slug", Page.ShowView, slug: :slug

    get "/feed", FeedController, :index
    live "/", Post.IndexView

    # If nothing else matches, 404
    get("/*path", RedirectController, :redirect)
  end
end
