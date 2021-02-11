defmodule NoozoWeb.Admin.Gallery.CreateView do
  @moduledoc """
  Admin Gallery create live view
  """
  use Phoenix.LiveView
  alias Noozo.Gallery
  alias NoozoWeb.Admin.Gallery.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    Creating gallery image...
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:ok, image} = Gallery.create_image(%{title: "Untitled Image"})

    {:noreply,
     socket
     |> put_flash(:info, "Image created")
     |> redirect(to: Routes.live_path(socket, EditView, image.uuid))}
  end
end
