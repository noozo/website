defmodule NoozoWeb.Admin.Post.CreateView do
  @moduledoc """
  Admin posts create live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Core
  alias NoozoWeb.Admin.Post.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  @impl true
  def render(assigns) do
    ~H"""
    Creating post...
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
