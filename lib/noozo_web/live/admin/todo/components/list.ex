defmodule NoozoWeb.Admin.Todo.Components.List do
  @moduledoc """
  List component
  """
  use Phoenix.LiveComponent

  alias Noozo.Repo
  alias Noozo.Todo

  import Ecto.Query, warn: false

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="bg-gray-100 text-sm rounded-lg p-4 border border-gray-300 shadow list"
         phx-hook="Draggable" draggable="true"
         phx-value-draggable_id="<%= @list.id %>"
         phx-value-draggable_type="list"
         phx-value-list_id="<%= @list.id %>"
         style="min-width: 250px; max-width: 250px;">
      <div phx-hook="DropContainer" id="<%= @id %>_drop_container" class="h-full flex flex-col gap-2">
        <%= live_component @socket, NoozoWeb.Admin.Todo.Components.ListHeader, id: "list_header_#{@list.id}", list: @list %>
        <div class="flex flex-col gap-1">
          <%= if @list.open do %>
            <%= for item <- @list.items |> Enum.sort_by(&(&1.inserted_at)) do %>
              <%= live_component @socket, NoozoWeb.Admin.Todo.Components.Item, id: item.id, search_result_ids: @search_result_ids %>
            <% end %>
            <%= live_component @socket, NoozoWeb.Admin.Todo.Components.ItemCreator, id: "item_creator_#{@list.id}", list: @list %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Converts list_id in assigns into list, by smartly identifying all
  # components in the same page and running a single query to get all lists
  # instead of N+1'ing
  @impl true
  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    item_preload =
      from(
        i in Todo.Item,
        order_by: [asc: i.inserted_at]
      )

    query =
      from(
        list in Todo.List,
        where: list.id in ^list_of_ids,
        order_by: [desc: :order],
        select: {list.id, list},
        left_join: item in assoc(list, :items),
        preload: [
          items: ^item_preload
        ]
      )

    lists = Map.new(Repo.all(query))

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :list, lists[assigns.id])
    end)
  end

  @impl true
  def update(%{id: id, list: list, search_result_ids: search_result_ids} = _assigns, socket) do
    {:ok, assign(socket, id: id, list: list, search_result_ids: search_result_ids)}
  end
end
