defmodule NoozoWeb.Admin.Gallery.CreateView do
  @moduledoc """
  Admin Gallery create live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Gallery
  alias NoozoWeb.Admin.Gallery.EditView

  @impl true
  def render(assigns) do
    ~F"""
    Creating gallery image...
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:ok, image} = Gallery.create_image(%{title: "Untitled Image"})

    {:noreply,
     socket
     |> put_flash(:info, "Image created")
     |> redirect(to: Routes.live_path(socket, EditView, image.uuid))}
  end
end
