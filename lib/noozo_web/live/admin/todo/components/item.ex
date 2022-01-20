defmodule NoozoWeb.Admin.Todo.Components.Item do
  @moduledoc """
  Item component
  """
  use Phoenix.LiveComponent

  alias Noozo.Repo
  alias Noozo.Todo

  import Ecto.Query, warn: false

  @impl true
  def update(%{id: id, item: item, search_result_ids: search_result_ids} = _assigns, socket) do
    # Update opacity depending if id is in search_result_ids (the ones that didnt match)
    opacity = if search_result_ids == [] or Enum.member?(search_result_ids, id), do: 100, else: 20
    {:ok, assign(socket, id: id, item: item, opacity: opacity)}
  end

  @impl true
  def update(%{id: id, item: item} = _assigns, socket) do
    {:ok, assign(socket, id: id, item: item, opacity: 100)}
  end

  # Converts id in assigns into item, by smartly identifying all
  # components in the same page and running a single query to get all items
  # instead of N+1'ing
  @impl true
  def preload(list_of_assigns) do
    list_of_ids =
      list_of_assigns
      |> Enum.reject(&(not is_nil(&1[:item])))
      |> Enum.map(& &1.id)

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
  def render(%{item: item, opacity: opacity} = assigns) do
    label_bg = if item.label, do: item.label.color_hex, else: "white"
    label_color = if item.label, do: item.label.text_color_hex, else: "black"
    opacity = opacity / 100

    hardcoded_styles =
      "background-color: #{label_bg}; color: #{label_color}; opacity: #{opacity};"

    ~H"""
    <div id={@id}
         class="p-1 pl-2 pr-2 hover:bg-opacity-50 border cursor-pointer text-xs rounded-md"
         phx-hook="Draggable"
         draggable="true"
         phx-value-draggable_id={@item.id}
         phx-value-draggable_type="item"
         phx-click="item_clicked"
         style={hardcoded_styles}>
      <%= @item.title %>
      <%= if @item.content do %>
        <div class="tag-xs bg-white">...</div>
      <% end %>
    </div>
    """
  end
end
