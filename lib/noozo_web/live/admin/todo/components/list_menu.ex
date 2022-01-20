defmodule NoozoWeb.Admin.Todo.Components.ListMenu do
  @moduledoc """
  List menu component
  """
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="relative inline-block text-left" x-data="{showing: false}">
      <div>
        <button type="button" class="tag-xs" id={"#{@id}-menu"} aria-haspopup="true" aria-expanded="true"
                x-on:click="{showing = !showing}">
          <!-- Heroicon name: solid/chevron-down -->
          <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>

      <template x-if="showing">
        <div class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5"
            x-transition:enter="transition ease-out duration-100"
            x-transition:enter-start="transform opacity-0 scale-95"
            x-transition:enter-end="transform opacity-100 scale-100"
            x-transition:leave="transition ease-in duration-75"
            x-transition:leave-start="transform opacity-100 scale-100"
            x-transition:leave-end="transform opacity-0 scale-95">
          <div class="py-1" role="menu" aria-orientation="vertical" aria-labelledby={"#{@id}-menu"}>
            <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900"
              data-confirm="Are you sure?"
              phx-click="delete_list"
              phx-value-list_id={@list.id}
              phx-value-board_id={@list.board_id}>
              Delete
            </a>
          </div>
        </div>
      </template>
    </div>
    """
  end

  @impl true
  def update(%{id: id, list: list} = _assigns, socket) do
    {:ok, assign(socket, id: id, list: list)}
  end
end
