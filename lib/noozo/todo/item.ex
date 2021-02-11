defmodule Noozo.Todo.Item do
  @moduledoc """
    A TODO item, belongs to a list
  """
  use Noozo.Schema
  import Ecto.Changeset
  alias Noozo.Todo.{Label, List}

  schema "items" do
    field :title, :string
    field :content, :string
    belongs_to :list, List
    belongs_to :label, Label, foreign_key: :label_id, references: :id, type: :integer
    timestamps()
  end

  @required_fields [:title, :list_id]
  @optional_fields [:content, :label_id]

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
