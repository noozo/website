defmodule NoozoWeb.Admin.Cvs.Children.Components.HeaderItem do
  @moduledoc """
  Header item component
  """
  use NoozoWeb, :surface_component

  alias Noozo.Cvs

  require Logger

  prop item, :struct, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div id={@id}>
      <form phx-change="save" phx-debounce="500">
        <input
          class="mr-4 flex-col"
          type="text"
          name="content"
          phx-debounce="500"
          value={@item.content}
        />
      </form>
    </div>
    """
  end

  @impl true
  def update(%{id: id, item: item} = _assigns, socket) do
    {:ok, assign(socket, id: id, item: item)}
  end

  @impl true
  def handle_event("save", %{"content" => content} = _event, socket) do
    {:ok, item} = Cvs.update_header_item(socket.assigns.item, %{content: content})
    {:noreply, assign(socket, :item, item)}
  end
end
