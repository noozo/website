defmodule NoozoWeb.Admin.Todo.Board.IndexView do
  @moduledoc """
  List all the boards
  """
  use NoozoWeb, :surface_view

  alias Noozo.Pagination
  alias Noozo.Todo

  alias NoozoWeb.Admin.Todo.Board.CreateView
  alias NoozoWeb.Admin.Todo.Board.EditView
  alias NoozoWeb.Admin.Todo.Board.ShowView

  data loading, :boolean, default: true

  @impl true
  def render(assigns) do
    ~F"""
    {#if @loading}
      <div>Loading information...</div>
    {#else}
      <LivePatch to={Routes.live_path(@socket, CreateView)}>Create Board</LivePatch>
      <div class="boards">
        <table class="table">
          <thead>
            <th>Title</th>
            <th>Rename</th>
            <th>Created at</th>
          </thead>
          <tbody>
            {#for board <- @boards.entries}
              <tr>
                <td>
                  <LivePatch to={Routes.live_path(@socket, ShowView, board.id)}>{board.title}</LivePatch>
                </td>
                <td>
                  <LivePatch to={Routes.live_path(@socket, EditView, board.id)}>Rename</LivePatch>
                </td>
                <td>{TemplateUtils.format_date(board.inserted_at)}</td>
              </tr>
            {/for}
          </tbody>
        </table>
      </div>

      <Pagination source_assigns={assigns} entries={@boards} module={__MODULE__} />
    {/if}
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
