defmodule NoozoWeb.Admin.Todo.Board.CreateView do
  @moduledoc """
  Create boards
  """
  use NoozoWeb, :live_view

  alias Noozo.Todo

  @impl true
  def render(assigns) do
    ~H"""
    Creating board...
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:ok, board} = Todo.create_board(%{title: "Untitled"})

    {:noreply,
     socket
     |> put_flash(:info, "Board started")
     |> redirect(to: ~p"/admin/todo/boards/#{board.id}/edit")}
  end
end
