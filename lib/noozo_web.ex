defmodule NoozoWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use NoozoWeb, :controller
      use NoozoWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: NoozoWeb

      import Plug.Conn
      import NoozoWeb.Gettext
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      alias NoozoWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/noozo_web/templates",
        namespace: NoozoWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      unquote(view_helpers())
    end
  end

  def surface_view do
    quote do
      use Surface.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def surface_component do
    quote do
      use Surface.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import NoozoWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import NoozoWeb.ErrorHelpers
      import NoozoWeb.Gettext

      alias NoozoWeb.Router
      alias NoozoWeb.Router.Helpers, as: Routes
      alias NoozoWeb.TemplateUtils
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
