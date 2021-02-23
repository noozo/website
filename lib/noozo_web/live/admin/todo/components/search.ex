defmodule NoozoWeb.Admin.Todo.Components.Search do
  @moduledoc """
  Search component to highlight items in board
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  @impl true
  def update(%{id: id} = _assigns, socket) do
    {:ok, assign(socket, id: id)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="mb-6">
      <form phx-change="search" phx-target="<%= @myself %>">
        <div class="grid grid-cols-6 gap-6">
          <div class="col-span-6 sm:col-span-3">
            <label for="title">Search</label>
            <div class="mt-1">
              <input type="text" name="q" phx-debounce="500" />
            </div>
          </div>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"q" => q} = _event, socket) do
    if String.length(q) > 2 do
      item_ids = Todo.search_items(q)
      Phoenix.PubSub.broadcast!(Noozo.PubSub, "todo_item_search", {:item_search_hit, item_ids})
    else
      Phoenix.PubSub.broadcast!(Noozo.PubSub, "todo_item_search", :item_search_clear)
    end

    {:noreply, socket}
  end
end
