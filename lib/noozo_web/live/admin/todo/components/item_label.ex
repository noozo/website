defmodule NoozoWeb.Admin.Todo.Components.ItemLabel do
  @moduledoc """
  Show a label for a single item
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="flex flex-col">
      <div class="text-xs">Label</div>
      <div class="flex flex-row gap-2">
        <%= for label <- Todo.list_labels() do %>
          <% border = if label.id == @item.label_id, do: "ring-4 ring-gray-400", else: "" %>
          <div class="text-xs text-center align-middle h-8 p-2 cursor-pointer rounded-lg <%= border %>"
               style="background-color: <%= label.color_hex %>"
               phx-click="select_label"
               phx-value-label_id="<%= label.id %>"
               phx-target="<%= @myself %>">
            <%= label.title %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"item" => item} = _params, _session, socket) do
    {:ok, assign(socket, item: item)}
  end

  def handle_event(
        "select_label",
        %{"label_id" => label_id} = _event,
        %{assigns: assigns} = socket
      ) do
    label_id = String.to_integer(label_id)

    {:ok, item} =
      if label_id == assigns.item.label_id do
        Todo.set_item_label(assigns.item.id, nil)
      else
        Todo.set_item_label(assigns.item.id, label_id)
      end

    Phoenix.PubSub.broadcast!(Noozo.PubSub, "items", %{action: :labeled, id: item.id})
    {:noreply, assign(socket, item: item)}
  end
end
