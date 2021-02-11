defmodule Noozo.Core.Tag do
  @moduledoc """
    A generic tag, that can be used to tag multiple models
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :taggings_count, :integer
  end

  @doc false
  def changeset(tag, attrs \\ %{}) do
    tag
    |> cast(attrs, [:name, :taggings_count])
    |> validate_required([:name])
  end
end
