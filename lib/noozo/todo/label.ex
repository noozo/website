defmodule Noozo.Todo.Label do
  @moduledoc """
    A TODO label
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "labels" do
    field :title, :string
    field :color_hex, :string
    timestamps()
  end

  @required_fields [:color_hex]
  @optional_fields [:title]

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
