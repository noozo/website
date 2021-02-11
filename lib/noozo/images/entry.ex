defmodule Noozo.Images.Entry do
  @moduledoc """
  A generic image entry
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :string, autogenerate: false}

  schema "images" do
    field :path, :string

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :key,
      :path
    ])
    |> validate_required([:key, :path])
  end
end
