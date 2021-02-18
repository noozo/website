defmodule NoozoWeb.Admin.Page.CreateView do
  @moduledoc """
  Admin pages create live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Core
  alias NoozoWeb.Admin.Page.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    Creating page...
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    # {:noreply, assign(socket, page: %Page{})}
    {:ok, page} = Core.create_page(%{title: "Untitled", content: "Start writing..."})

    {:noreply,
     socket
     |> put_flash(:info, "Page started")
     |> redirect(to: Routes.live_path(socket, EditView, page.id))}
  end
end
