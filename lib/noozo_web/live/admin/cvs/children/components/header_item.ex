defmodule NoozoWeb.Admin.Cvs.Children.Components.HeaderItem do
  @moduledoc """
  Header item component
  """
  use Phoenix.LiveComponent

  alias Noozo.Cvs

  require Logger

  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <form phx-change="save" phx-debounce="500" phx-target="<%= @myself %>">
          <input class='mr-4 flex-col shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md'
                  type='text' name='content' phx-debounce="500" value='<%= @item.content %>' />
        </form>
      </div>
    """
  end

  def update(%{id: id, item: item} = _assigns, socket) do
    {:ok, assign(socket, id: id, item: item)}
  end

  def handle_event("save", %{"content" => content} = _event, socket) do
    {:ok, item} = Cvs.update_header_item(socket.assigns.item, %{content: content})
    {:noreply, assign(socket, :item, item)}
  end

  def handle_info({event, _cv}, socket) do
    Logger.debug("HeaderItem - Unhandled event: #{event}")
    {:noreply, socket}
  end
end
