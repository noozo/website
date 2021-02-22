defmodule NoozoWeb.Admin.Todo.Components.Item do
  @moduledoc """
  Item component
  """
  use Phoenix.LiveComponent

  alias Noozo.Repo
  alias Noozo.Todo

  import Ecto.Query, warn: false

  @impl true
  def update(%{id: id, item: item, item_search_hit: true} = assigns, socket) do
    {:ok, assign(socket, id: id, item: item, item_search_hit: true)}
  end

  @impl true
  def update(%{id: id, item: item} = assigns, socket) do
    {:ok, assign(socket, id: id, item: item, item_search_hit: false)}
  end

  # Converts id in assigns into item, by smartly identifying all
  # components in the same page and running a single query to get all items
  # instead of N+1'ing
  @impl true
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

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>"
         class="p-1 pl-2 pr-2 hover:bg-opacity-50 border cursor-pointer text-xs rounded-md <%= search_hit_classes(@item_search_hit) %>"
         phx-hook="Draggable"
         draggable="true"
         phx-value-draggable_id="<%= @item.id %>"
         phx-value-draggable_type="item"
         phx-click="item_clicked"
         style="background-color: <%= if @item.label, do: @item.label.color_hex, else: "white" %>; color: <%= if @item.label, do: @item.label.text_color_hex, else: "black" %>">
      <%= @item.title %>
      <%= if @item.content do %>
        <div class="tag-xs bg-white">...</div>
      <% end %>
    </div>
    """
  end

  defp search_hit_classes(true), do: "opacity-10"
  defp search_hit_classes(false), do: ""
end
