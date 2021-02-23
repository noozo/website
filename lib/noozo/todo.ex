defmodule Noozo.Todo do
  @moduledoc """
  The TODOs context.
  """
  import Ecto.Query, warn: false

  alias Noozo.Repo
  alias Noozo.Todo.{Board, Item, Label, List}

  def list_boards(params \\ %{page: 1, per_page: 10}) do
    Board
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
  end

  ################### BOARDS ####################

  def get_board!(id) do
    # Ordered lists
    lists_query =
      order_by(
        from(
          lists in List,
          where: lists.board_id == ^id,
          left_join: items in assoc(lists, :items),
          left_join: label in assoc(items, :label),
          order_by: lists.order,
          preload: [
            items: {
              items,
              [
                label: label
              ]
            }
          ]
        ),
        desc: :inserted_at
      )

    # Now get the board and pin the ordered lists preloaded
    Repo.one(
      from(
        board in Board,
        where: board.id == ^id,
        preload: [lists: ^lists_query]
      )
    )
  end

  def create_board(attributes) do
    %Board{}
    |> Board.changeset(attributes)
    |> Repo.insert()
  end

  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  ################### LISTS ####################

  def get_list!(id) do
    List
    |> Repo.get_by!(id: id)
    |> Repo.preload([
      {:items, from(i in Item, order_by: i.inserted_at)}
    ])
  end

  def get_list_by_order!(order) do
    List
    |> Repo.get_by!(order: order)
    |> Repo.preload([
      {:items, from(i in Item, order_by: i.inserted_at)}
    ])
  end

  def swap_lists(list1, list2) do
    tmp = list1.order

    Repo.transaction(fn ->
      {:ok, list1} =
        list1
        |> List.changeset(%{order: list2.order})
        |> Repo.update()

      {:ok, _list2} =
        list2
        |> List.changeset(%{order: tmp})
        |> Repo.update()

      list1
    end)
    |> broadcast(:lists_swapped, list2.id)
  end

  def create_list(attributes) do
    Repo.transaction(fn ->
      new_id = Repo.one(from(l in "lists", select: count(l.id)))

      %List{}
      |> List.changeset(Map.merge(attributes, %{order: new_id + 1}))
      |> Repo.insert()
    end)
    |> broadcast(:list_created)
  end

  def delete_list(list_id) do
    %List{id: list_id}
    |> Repo.delete()
    |> broadcast(:list_deleted)
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
    |> broadcast(:list_updated)
  end

  def toggle_list(list_id) do
    list = get_list!(list_id)

    list
    |> List.changeset(%{open: !list.open})
    |> Repo.update()
    |> broadcast(:list_toggled)
  end

  ################### ITEMS ####################

  def get_item!(id) do
    Repo.one(
      from(
        item in Item,
        where: item.id == ^id,
        left_join: label in assoc(item, :label),
        preload: [label: label]
      )
    )
  end

  def search_items(q) do
    q = ~s(%#{String.downcase(q)}%)

    query =
      from(
        item in Item,
        where:
          fragment("lower(title) like ?", ^q) or
            fragment("lower(content) like ?", ^q),
        select: [:id]
      )

    query
    |> Repo.all()
    |> Enum.map(& &1.id)
  end

  def create_item(attributes) do
    %Item{}
    |> Item.changeset(attributes)
    |> Repo.insert()
    |> broadcast(:item_created)
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
    |> broadcast(:item_updated)
  end

  def delete_item(item) do
    {:ok, _item} = Repo.delete(item)
    {:ok, item} |> broadcast(:item_deleted)
  end

  def move_item_to(item_id, list_id) do
    item = get_item!(item_id)
    previous_list_id = item.list_id

    item
    |> Item.changeset(%{list_id: list_id})
    |> Repo.update()
    |> broadcast(:item_moved, previous_list_id)
  end

  def set_item_label(item_id, label_id) do
    item_id
    |> get_item!()
    |> Item.changeset(%{label_id: label_id})
    |> Repo.update()
    |> broadcast(:item_label_changed)
  end

  ################### LABELS ####################

  def list_labels do
    Label |> Repo.all()
  end

  def list_labels(params) do
    query = from(l in Label, order_by: [desc: :id])
    Repo.paginate(query, params)
  end

  def get_label!(id) do
    Label
    |> Repo.get_by!(id: id)
  end

  def create_label(attributes) do
    case Repo.get_by(Label, attributes) do
      nil ->
        %Label{}
        |> Label.changeset(attributes)
        |> Repo.insert()

      existing ->
        existing
    end
  end

  def update_label(label_id, attrs) do
    Label
    |> Repo.get!(label_id)
    |> Label.changeset(attrs)
    |> Repo.update()
  end

  ################### BROADCASTING ####################

  def subscribe do
    Phoenix.PubSub.subscribe(Noozo.PubSub, "todo")
  end

  defp broadcast({:ok, object} = result, :item_moved = event, previous_list_id) do
    Phoenix.PubSub.broadcast!(Noozo.PubSub, "todo", {event, object, previous_list_id})
    result
  end

  defp broadcast({:ok, object} = result, :lists_swapped = event, other_list_id) do
    Phoenix.PubSub.broadcast!(Noozo.PubSub, "todo", {event, object, other_list_id})
    result
  end

  defp broadcast({:ok, object} = result, event) do
    Phoenix.PubSub.broadcast!(Noozo.PubSub, "todo", {event, object})
    result
  end

  defp broadcast({:error, _reason} = error, _event), do: error
end
