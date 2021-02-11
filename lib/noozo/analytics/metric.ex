defmodule Noozo.Analytics.Metric do
  @moduledoc """
    An analytics metric entry
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "metrics" do
    field :date, :date, primary_key: true
    field :path, :string, primary_key: true
    field :counter, :integer, default: 0
    field :post_id, :integer
  end

  @required_fields [:date, :path]
  @optional_fields [:counter, :post_id]

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
