defmodule NoozoWeb.Admin.Todo.Components.Item do
  @moduledoc """
  Item component
  """
  use Phoenix.LiveComponent

  alias Noozo.Repo
  alias Noozo.Todo

  import Ecto.Query, warn: false

  def render(assigns) do
    ~L"""
    <div id="<%= @id %>"
         class="p-1 pl-2 pr-2 bg-white hover:bg-blue-100 border cursor-pointer text-xs rounded-md"
         phx-hook="Draggable"
         draggable="true"
         phx-value-draggable_id="<%= @item.id %>"
         phx-value-draggable_type="item"
         phx-click="item_clicked">
      <%= @item.title %>
      <%= if @item.label do %>
        <div class="tag-xs text-xs inline" style="background-color: <%= @item.label.color_hex %>"></div>
      <% end %>
    </div>
    """
  end

  # Converts id in assigns into item, by smartly identifying all
  # components in the same page and running a single query to get all items
  # instead of N+1'ing
  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    query =
      from(
        item in Todo.Item,
        where: item.id in ^list_of_ids,
        select: {item.id, item},
        left_join: label in assoc(item, :label),
        preload: [label: label]
      )

    items =
      query
      |> Repo.all()
      |> Map.new()

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :item, items[assigns.id])
    end)
  end

  def update(assigns, socket) do
    {:ok, assign(socket, id: assigns.id, item: assigns.item)}
  end
end
