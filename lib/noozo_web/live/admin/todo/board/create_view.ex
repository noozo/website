defmodule NoozoWeb.Admin.Todo.Board.CreateView do
  @moduledoc """
  Create boards
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    Creating board...
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:ok, board} = Todo.create_board(%{title: "Untitled"})

    {:noreply,
     socket
     |> put_flash(:info, "Board started")
     |> redirect(to: Routes.live_path(socket, EditView, board.id))}
  end
end
