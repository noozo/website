defmodule NoozoWeb.Admin.Todo.Components.ItemCreator do
  @moduledoc """
  Item creator component
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="new-item">
      <%= if @creating do %>
        <form phx-submit="create_item" phx-target="<%= @myself %>">
          <input type="hidden" name="list_id" value="<%= @list.id %>" />
          <div class="field is-grouped">
            <div class="control">
              <input class="input is-small" type="text" name="new_item" placeholder="Enter item title..." size="15" phx-hook="Focus" data-component="<%= @id %>" id="<%= @id %>" />
            </div>
            <div class="control">
              <button class="button is-small is-success"><i class="material-icons">check</i></button>
            </div>
          </div>
        </form>
        <form phx-submit="cancel" phx-target="<%= @myself %>">
          <button class="button is-small is-danger is-right"><i class="material-icons">cancel</i></button>
        </form>
      <% else %>
        <form phx-submit="input_title" phx-target="<%= @myself %>">
          <button class="new-item"><i class="material-icons">add</i> Add another item</button>
        </form>
      <% end %>
      </div>
    """
  end

  @impl true
  def update(%{id: id, list: list} = _assigns, socket) do
    {:ok, assign(socket, id: id, list: list, creating: false)}
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
