defmodule NoozoWeb.Admin.Todo.Board.CreateView do
  @moduledoc """
  Create boards
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  @impl true
  def render(assigns) do
    ~H"""
    Creating board...
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:ok, board} = Todo.create_board(%{title: "Untitled"})

    {:noreply,
     socket
     |> put_flash(:info, "Board started")
     |> redirect(to: Routes.live_path(socket, EditView, board.id))}
  end
end
