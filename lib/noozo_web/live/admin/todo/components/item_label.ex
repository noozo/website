defmodule NoozoWeb.Admin.Todo.Components.ItemLabel do
  @moduledoc """
  Show a label for a single item
  """
  use Phoenix.LiveComponent

  alias Noozo.Todo

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="flex">
      <h6><small>Label</small></h6>
      <%= for label <- Todo.list_labels() do %>
        <% border = if label.id == @item.label_id, do: "5px solid rgba(0,0,0,.15);", else: "none" %>
        <div class="d-inline label cursor-pointer" style="background-color: <%= label.color_hex %>; border: <%= border %>"
             phx-click="select_label" phx-value-label_id="<%= label.id %>" phx-target="<%= @myself %>">
          <%= label.title %>
        </div>
      <% end %>
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
