defmodule NoozoWeb.Admin.Todo.Components.ListCreator do
  @moduledoc """
  List creator component
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="bg-black bg-opacity-25 hover:bg-opacity-30 text-sm rounded-lg p-4" style="min-width: 250px;">
      <%= if @creating do %>
        <form phx-submit="create_list" phx-target="<%= @myself %>">
          <input type="hidden" name="board_id" value="<%= @board.id %>" />
          <div class="flex flex-col gap-2">
            <div class="flex-grow">
              <input class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 w-full sm:text-sm border-gray-300 rounded-md"
                     type="text" name="new_list" placeholder="Enter list title..." size="15" phx-hook="Focus" data-component="<%= @id %>" id="<%= @id %>" />
            </div>
            <div class="flex flex-row gap-2">
              <div class="flex-grow">
                <input type="submit" class="tag-xs text-xs" value="Create" />
              </div>
              <div phx-click="cancel" phx-target="<%= @myself %>" class="tag-xs text-xs is-small is-danger is-right">
                <i class="material-icons">cancel</i>
              </div>
            </div>
          </div>
        </form>
      <% else %>
        <form phx-submit="input_title" phx-target="<%= @myself %>">
          <button class="new-list"><i class="material-icons">add</i> Add another list</button>
        </form>
      <% end %>
      </div>
    """
  end

  @impl true
  def update(%{id: id, board: board} = _assigns, socket) do
    {:ok, assign(socket, id: id, board: board, creating: false)}
  end

  @impl true
  def handle_event("input_title", _event, socket) do
    {:noreply, assign(socket, board: socket.assigns.board, creating: true)}
  end

  @impl true
  def handle_event("cancel", _event, socket) do
    {:noreply, assign(socket, board: socket.assigns.board, creating: false)}
  end

  ###################### PubSub Events ######################

  @impl true
  def handle_event("create_list", %{"new_list" => title} = _event, socket) do
    {:ok, _new_list} = Todo.create_list(%{title: title, board_id: socket.assigns.board.id})
    {:noreply, socket}
  end
end
