defmodule NoozoWeb.Admin.Todo.Components.Search do
  @moduledoc """
  Search component to highlight items in board
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  @impl true
  def update(%{id: id, current_user: current_user} = _assigns, socket) do
    {:ok, assign(socket, id: id, current_user: current_user)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="mb-6">
      <form phx-change="search" phx-target={@myself}>
        <div class="flex flex-row items-center gap-2">
          <label for="title">Search</label>
          <div class="mt-1">
            <input type="text" size="30" name="q" phx-debounce="500" />
          </div>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"q" => q} = _event, socket) do
    current_user = socket.assigns.current_user

    if String.length(q) > 2 do
      item_ids = Todo.search_items(q)

      Phoenix.PubSub.broadcast!(
        Noozo.PubSub,
        "todo_item_search_#{current_user.id}",
        {:item_search_hit, item_ids}
      )
    else
      Phoenix.PubSub.broadcast!(
        Noozo.PubSub,
        "todo_item_search_#{current_user.id}",
        :item_search_clear
      )
    end

    {:noreply, socket}
  end
end
