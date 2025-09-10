defmodule NoozoWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use NoozoWeb, :controller
      use NoozoWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import NoozoWeb.Gettext
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json], layouts: [html: NoozoWeb.LayoutView]
      import NoozoWeb.Gettext

      import Plug.Conn
      import Phoenix.LiveView.Controller, only: [live_render: 3]

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, :live}

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/noozo_web/templates",
        namespace: NoozoWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      import NoozoWeb.Gettext

      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      # Import LiveView and Component helpers
      import Phoenix.LiveView.Helpers
      import Phoenix.Component

      # Import basic rendering functionality
      import Phoenix.View

      import NoozoWeb.ErrorHelpers
      import NoozoWeb.Gettext

      # Routes generation with verified routes
      unquote(verified_routes())

      alias NoozoWeb.TemplateUtils

      # Common modules used in templates
      alias Phoenix.LiveView.JS
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: NoozoWeb.Endpoint,
        router: NoozoWeb.Router,
        statics: NoozoWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
