defmodule NoozoWeb.Admin.Todo.Components.ItemModal.Content do
  @moduledoc """
  Item modal content, supports edition
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
        <form class="" submit="update_content">
          <div class="flex flex-col gap-6">
            <textarea
              class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 w-full h-64 sm:text-sm border-gray-300 rounded-md"
              type="text"
              name="content"
              data-component={@id}
              id={@id}
            >{@item.content}</textarea>

            <div class="flex flex-row gap-2">
              <div class="flex-grow">
                <input type="submit" class="tag-xs text-xs cursor-pointer" value="Update">
              </div>
              <div
                phx-click="cancel"
                phx-target={@myself}
                class="tag-xs text-xs is-small is-danger is-right cursor-pointer"
              >
                <i class="material-icons">cancel</i>
              </div>
            </div>
          </div>
        </form>
      {#else}
        <div
          class="text-xs flex flex-col rounded-lg border-2 border-dashed p-4 prose"
          phx-click="start_editing"
          phx-target={@myself}
        >
          {#if @item.content}
            <div>
              {(@item.content || "") |> Earmark.as_html!() |> Phoenix.HTML.raw()}
            </div>
          {#else}
            <div>There is nothing here. Click to edit.</div>
          {/if}
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
  def handle_event("update_content", %{"content" => new_content} = _event, socket) do
    {:ok, item} = Todo.update_item(socket.assigns.item, %{content: new_content})
    {:noreply, assign(socket, item: item, editing: false)}
  end
end
