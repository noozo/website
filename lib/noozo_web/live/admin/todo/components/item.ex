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
         class="p-1 bg-white rounded-lg border shadow cursor-pointer mb-2 max-w-92 min-h-12 relative"
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

  # padding: 5px;
  #   background-color: #fff;
  #   border-radius: 3px;
  #   box-shadow: 0px 1px #427aa144;
  #   &:hover {
  #       box-shadow: 2px 2px 2px 2px #427aa144;
  #   }
  #   cursor: pointer;
  #   display: block;
  #   margin-bottom: 8px;
  #   max-width: 300px;
  #   min-height: 20px;
  #   position: relative;
  #   text-decoration: none;
  #   word-wrap: break-word;

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
