defmodule Noozo.Todo.List do
  @moduledoc """
    A TODO list, belongs to a board
  """
  use Noozo.Schema
  import Ecto.Changeset
  alias Noozo.Todo.{Board, Item}

  schema "lists" do
    field :title, :string
    field :order, :integer
    field :open, :boolean
    belongs_to :board, Board
    has_many :items, Item
    timestamps()
  end

  @required_fields [:title, :board_id]
  @optional_fields [:order, :open]

  @doc """
  Creates a changeset based on the `model` and `params`.
  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
