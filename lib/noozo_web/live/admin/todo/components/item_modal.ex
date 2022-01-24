defmodule NoozoWeb.Admin.Todo.Components.ItemModal do
  @moduledoc """
  Show a modal for a single item
  """
  use NoozoWeb, :surface_component

  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Components.ItemLabel
  alias NoozoWeb.Admin.Todo.Components.ItemModal.{Content, Title}

  prop item, :struct, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div
      id={@id}
      class="z-10 inset-0 overflow-y-auto"
      :class="{'fixed': modalOpen, 'hidden': !modalOpen}"
    >
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div
          class="fixed inset-0 transition-opacity"
          x-show="modalOpen"
          aria-hidden="true"
          phx-click="item_clicked"
          phx-value-draggable_id=""
        >
          <div class="absolute inset-0 bg-gray-500 opacity-75" />
        </div>

        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <div
          class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full"
          x-show="modalOpen"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-headline"
        >
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start gap-8">
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <Title id={:item_title} item={@item} />

                <div class="mt-2 flex flex-col gap-6">
                  <ItemLabel id={:label} item={@item} />

                  <Content id={:item_content} item={@item} />

                  <div class="text-xs">
                    <a
                      href="#"
                      data-confirm="Are you sure?"
                      class="text-red-800"
                      phx-click="delete_item"
                      phx-target={@myself}
                    >Delete this item</a>.
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button
              type="button"
              class="btn"
              data-dismiss="modal"
              phx-click="item_clicked"
              phx-value-draggable_id=""
            >Close</button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("delete_item", _event, socket) do
    {:ok, _item} = Todo.delete_item(socket.assigns.item)
    {:noreply, socket}
  end
end
