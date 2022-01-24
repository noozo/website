defmodule NoozoWeb.Admin.Post.CreateView do
  @moduledoc """
  Admin posts create live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Core
  alias NoozoWeb.Admin.Post.EditView

  @impl true
  def render(assigns) do
    ~F"""
    Creating post...
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:ok, post} =
      Core.create_post(%{title: "Untitled", content: "Start writing...", status: "draft"})

    {:noreply,
     socket
     |> put_flash(:info, "Post started")
     |> redirect(to: Routes.live_path(socket, EditView, post.id))}
  end
end
