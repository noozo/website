defmodule NoozoWeb.Admin.Todo.Components.ItemModal.Title do
  @moduledoc """
  Item modal title, supports edition
  """
  use NoozoWeb, :surface_component

  alias Noozo.Todo

  prop item, :struct, required: true
  data editing, :boolean, default: false

  @impl true
  def render(assigns) do
    ~F"""
    <div id={@id}>
      {#if @editing}
        <form class="" submit="update_title">
          <div class="flex flex-row gap-6">
            <input
              class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 w-full sm:text-sm border-gray-300 rounded-md"
              type="text"
              name="title"
              phx-hook="Focus"
              data-component={@id}
              value={@item.title}
              id={@id}
            />
          </div>
        </form>
      {#else}
        <div class="text-lg font-bold" click="start_editing">
          {@item.title}
        </div>
      {/if}
    </div>
    """
  end

  @impl true
  def handle_event("start_editing", _event, socket) do
    {:noreply, assign(socket, editing: true)}
  end

  @impl true
  def handle_event("cancel", _event, socket) do
    {:noreply, assign(socket, editing: false)}
  end

  @impl true
  def handle_event("update_title", %{"title" => new_title} = _event, socket) do
    {:ok, item} = Todo.update_item(socket.assigns.item, %{title: new_title})
    {:noreply, assign(socket, :item, item)}
  end
end
