defmodule NoozoWeb.Admin.Todo.Board.IndexView do
  @moduledoc """
  List all the boards
  """
  use NoozoWeb, :live_view

  alias Noozo.Pagination
  alias Noozo.Todo

  alias NoozoWeb.Admin.Todo.Board.CreateView
  alias NoozoWeb.Admin.Todo.Board.EditView
  alias NoozoWeb.Admin.Todo.Board.ShowView
  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <.link to={Routes.live_path(@socket, CreateView)}>Create Board</.link>
      <div class="boards">
        <table class="table">
          <thead>
            <th>Title</th>
            <th>Rename</th>
            <th>Created at</th>
          </thead>
          <tbody>
            <%= for board <- @boards.entries do %>
              <tr>
                <td>
                  <.link to={Routes.live_path(@socket, ShowView, board.id)}><%= board.title %></.link>
                </td>
                <td>
                  <.link to={Routes.live_path(@socket, EditView, board.id)}>Rename</.link>
                </td>
                <td><%= TemplateUtils.format_date(board.inserted_at) %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <%= Noozo.Pagination.render(%{source_assigns: assigns, entries: @boards, module: __MODULE__}) %>
    <% end %>
    """
  end

  @impl true
  def handle_info({:load_boards, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       boards: Todo.list_boards(params)
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    send(self(), {:load_boards, params})
    {:noreply, assign(socket, loading: true)}
  end
end
