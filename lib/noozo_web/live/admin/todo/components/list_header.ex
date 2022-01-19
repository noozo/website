defmodule NoozoWeb.Admin.Todo.Components.ListHeader do
  @moduledoc """
  Header of each list on the board
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  @impl true
  def update(%{id: id, list: list} = _assigns, socket) do
    {:ok, socket |> assign(:id, id) |> assign(:list, list) |> assign(:editing, false)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="flex flex-row text-xs">
      <%= if @editing do %>
        <form class="" phx-target="<%= @myself %>" phx-submit="update_title">
          <div class="flex flex-row gap-6">
            <input class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 w-full sm:text-sm border-gray-300 rounded-md"
                  type="text" name="title" phx-hook="Focus" data-component="<%= @id %>"
                  value="<%= @list.title %>" id="<%= @id %>"/>
          </div>
        </form>
      <% else %>
        <div>
          <div class="btn" phx-click="toggle_list" phx-value-list_id="<%= @list.id %>" phx-value-board_id="<%= @list.board_id %>">
            <%= if @list.open do %>-<% else %>+<% end %>
          </div>
        </div>
        <div class="flex-grow text-center py-2 text-sm" phx-click="start_editing" phx-target="<%= @myself %>">
          <%= @list.title %>
        </div>
        <div>
          <div class="tag-xs" phx-click="start_editing" phx-target="<%= @myself %>">
            <%= length(@list.items) %>
          </div>
        </div>
        <div>
          <%= live_component NoozoWeb.Admin.Todo.Components.ListMenu, id: "list_menu_#{@list.id}", list: @list %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("start_editing", _event, socket) do
    {:noreply, assign(socket, list: socket.assigns.list, editing: true)}
  end

  @impl true
  def handle_event("cancel", _event, socket) do
    {:noreply, assign(socket, list: socket.assigns.list, editing: false)}
  end

  @impl true
  def handle_event("update_title", %{"title" => new_title} = _event, socket) do
    {:ok, list} = Todo.update_list(socket.assigns.list, %{title: new_title})
    {:noreply, assign(socket, list: list, editing: false)}
  end
end
