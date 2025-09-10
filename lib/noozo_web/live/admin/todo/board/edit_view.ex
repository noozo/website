defmodule NoozoWeb.Admin.Todo.Board.EditView do
  @moduledoc """
  Edit board
  """
  use NoozoWeb, :live_view

  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.IndexView

  @impl true
  def render(assigns) do
    ~H"""
    <.link to={Routes.live_path(@socket, IndexView) }>Back to list</.link>

    <div class="notifications">
      <%= unless is_nil(@info) do %>
        <p class="alert alert-info" role="alert"><%= @info %></p>
      <% end %>
      <%= unless is_nil(@error) do %>
        <p class="alert alert-danger" role="alert"><%= @error %></p>
      <% end %>
    </div>

    <div class="edit-grid">
      <div class="column editing">
        <form phx-change="save">
          <div class="control-group">
            <label class="control-label" for="title-input">Title</label>
            <input class="form-control" type="text" name="title" value={@board.title} phx-debounce="500">
          </div>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, board: Todo.get_board!(params["id"]))}
  end

  @impl true
  def handle_event(
        "save",
        %{"_target" => _target, "title" => title} = _event,
        socket
      ) do
    {:ok, board} =
      Todo.update_board(socket.assigns.board, %{
        title: String.trim(title)
      })

    {:noreply, assign(socket, board: board, info: "Board saved")}
  end
end
