defmodule NoozoWeb.Admin.Todo.Board.EditView do
  @moduledoc """
  Edit board
  """
  use Phoenix.HTML
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.IndexView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    <%= live_patch "Back to list", to: Routes.live_path(@socket, IndexView) %>

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
          <div class='control-group'>
            <label class='control-label' for='title-input'>Title</label>
            <input class='form-control' type='text' name='title' value='<%= @board.title %>' phx-debounce="500" />
          </div>
        </form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, info: nil, error: nil)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, board: Todo.get_board!(params["id"]))}
  end

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
