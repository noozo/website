defmodule NoozoWeb.Admin.Page.CreateView do
  @moduledoc """
  Admin pages create live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Core
  alias NoozoWeb.Admin.Page.EditView

  @impl true
  def render(assigns) do
    ~F"""
    Creating page...
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:ok, page} = Core.create_page(%{title: "Untitled", content: "Start writing..."})

    {:noreply,
     socket
     |> put_flash(:info, "Page started")
     |> redirect(to: Routes.live_path(socket, EditView, page.id))}
  end
end
