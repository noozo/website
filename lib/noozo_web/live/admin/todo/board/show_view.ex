defmodule NoozoWeb.Admin.Todo.Board.ShowView do
  @moduledoc """
  Show a single board
  """
  use NoozoWeb, :surface_view

  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Components.ItemModal
  alias NoozoWeb.Admin.Todo.Components.List
  alias NoozoWeb.Admin.Todo.Components.ListCreator
  alias NoozoWeb.Admin.Todo.Components.Search

  prop board, :struct, required: true
  data search_result_ids, :list, default: []

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <div class="text-xl font-bold mb-6">
        Board: {@board.title}
      </div>
      <Search id={:search} current_user={@current_user} />
      <div
        class="bg-gray-200 p-5 rounded-lg border border-gray-300 overflow-scroll"
        style="max-width: 90vw"
      >
        <div class="lists flex flex-col sm:flex-row gap-6">
          {#for list <- @lists}
            <List id={list.id} search_result_ids={@search_result_ids} />
          {/for}
          <ListCreator id={:list_creator} board={@board} />
        </div>
      </div>
    </div>

    {#if @selected_item}
      <div x-data="{modalOpen: true}" x-title="Modal Background">
        <ItemModal id={:item_modal} item={@selected_item} />
      </div>
    {/if}
    """
  end

  @impl true
  def mount(%{"id" => id} = _params, %{"current_user" => current_user} = _session, socket) do
    if connected?(socket) do
      Todo.subscribe()
      Phoenix.PubSub.subscribe(Noozo.PubSub, "todo_item_search_#{current_user.id}")
    end

    board = Todo.get_board!(id)

    {:ok,
     assign(socket,
       board: board,
       lists: board.lists,
       columns: column_size(board),
       selected_item: nil,
       search_result_ids: [],
       current_user: current_user
     )}
  end

  @impl true
  def handle_event("toggle_list", %{"list_id" => id} = _event, socket) do
    {:ok, _list} = Todo.toggle_list(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_list", %{"list_id" => id} = _event, socket) do
    {:ok, _schema} = Todo.delete_list(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("move_item", %{"id" => item_id, "to_list_id" => list_id} = _event, socket) do
    list = Todo.get_list!(list_id)
    {:ok, _item} = Todo.move_item_to(item_id, list.id)
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "swap_lists",
        %{"id" => from_id, "to_list_id" => to_id} = _event,
        socket
      ) do
    source_list = Todo.get_list!(from_id)
    target_list = Todo.get_list!(to_id)
    {:ok, _list} = Todo.swap_lists(source_list, target_list)
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_event("item_clicked", %{"draggable_id" => ""} = _event, socket) do
    {:noreply, assign(socket, selected_item: nil)}
  end

  @impl true
  def handle_event("item_clicked", %{"draggable_id" => id} = _event, socket) do
    {:noreply, assign(socket, selected_item: Todo.get_item!(id))}
  end

  @impl true
  def handle_info(:load_board, socket) do
    board = Todo.get_board!(socket.assigns.board.id)

    {:noreply,
     assign(socket,
       board: board,
       lists: board.lists,
       columns: column_size(board)
     )}
  end

  ###################### PubSub Events ######################

  @impl true
  def handle_info({:lists_swapped, _list, _other_list}, socket) do
    # TODO: Maybe patch lists, instead of reloading everything
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_moved, item, previous_list_id}, socket) do
    # Send update to the appropriate lists
    send_update(Components.List, id: item.list_id)
    send_update(Components.List, id: previous_list_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_created, item}, socket) do
    # Send update to the appropriate list
    send_update(Components.List, id: item.list_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_updated, item}, socket) do
    # Send update to the appropriate item
    send_update(Components.Item, id: item.id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_deleted, item}, socket) do
    # Send update to the appropriate list
    send_update(Components.List, id: item.list_id)
    {:noreply, assign(socket, selected_item: nil)}
  end

  @impl true
  def handle_info({:item_label_changed, item}, socket) do
    # Send update to the appropriate item
    send_update(Components.Item, id: item.id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:list_created, _list}, socket) do
    # TODO: Maybe patch lists, instead of reloading everything
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:list_updated, list}, socket) do
    # Send update to the appropriate list
    send_update(Components.List, id: list.id, list: list)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:list_deleted, _list}, socket) do
    # TODO: Maybe patch lists, instead of reloading everything
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:list_toggled, _list}, socket) do
    # TODO: Maybe patch lists, instead of reloading everything
    send(self(), :load_board)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:item_search_hit, item_ids}, socket) do
    {:noreply, assign(socket, search_result_ids: item_ids)}
  end

  @impl true
  def handle_info(:item_search_clear, socket) do
    {:noreply, assign(socket, search_result_ids: [])}
  end

  defp column_size(board) do
    length(board.lists) + 1
  end
end
