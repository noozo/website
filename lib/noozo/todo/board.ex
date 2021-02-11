defmodule Noozo.Todo.Board do
  @moduledoc """
    A TODO board
  """
  use Noozo.Schema
  import Ecto.Changeset
  alias Noozo.Todo.{Item, List}

  schema "boards" do
    field :title, :string
    has_many :lists, List
    has_many :items, through: [:lists, Item]
    timestamps()
  end

  @required_fields [:title]
  @optional_fields []

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
