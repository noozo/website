defmodule NoozoWeb.Admin.Todo.Components.ItemCreator do
  @moduledoc """
  Item creator component
  """
  use NoozoWeb, :surface_component

  alias Noozo.Todo

  prop list, :struct, required: true
  data creating, :boolean, default: false

  @impl true
  def render(assigns) do
    ~F"""
    <div id={@id}>
      {#if @creating}
        <form phx-submit="create_item">
          <input type="hidden" name="list_id" value={@list.id}>
          <div class="flex flex-col gap-2">
            <div class="flex-grow">
              <input
                class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 w-full sm:text-sm border-gray-300 rounded-md"
                type="text"
                name="new_item"
                placeholder="Enter item title..."
                phx-hook="Focus"
                data-component={@id}
                id={@id}
              />
            </div>
            <div class="flex flex-row gap-2">
              <div class="flex-grow">
                <input type="submit" class="tag-xs text-xs" value="Create">
              </div>
              <div phx-click="cancel" class="tag-xs text-xs is-small is-danger is-right">
                <i class="material-icons">cancel</i>
              </div>
            </div>
          </div>
        </form>
      {#else}
        <form phx-submit="input_title">
          <button class="rounded text-black bg-gray-100 hover:bg-gray-200 p-4 w-full">
            + Add another item
          </button>
        </form>
      {/if}
    </div>
    """
  end

  @impl true
  def handle_event("input_title", _event, socket) do
    {:noreply, assign(socket, list: socket.assigns.list, creating: true)}
  end

  @impl true
  def handle_event("cancel", _event, socket) do
    {:noreply, assign(socket, list: socket.assigns.list, creating: false)}
  end

  ###################### PubSub Events ######################

  @impl true
  def handle_event("create_item", %{"new_item" => title, "list_id" => list_id} = _event, socket) do
    {:ok, _new_item} = Todo.create_item(%{title: title, list_id: list_id})
    {:noreply, socket}
  end
end
