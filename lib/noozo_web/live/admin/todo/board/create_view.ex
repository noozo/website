defmodule NoozoWeb.Admin.Todo.Board.CreateView do
  @moduledoc """
  Create boards
  """
  use NoozoWeb, :surface_view

  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.EditView

  @impl true
  def render(assigns) do
    ~F"""
    Creating board...
    """
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
