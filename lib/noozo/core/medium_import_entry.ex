defmodule Noozo.Core.MediumImportEntry do
  @moduledoc """
  Stores import results from medium, so we don't re-add
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "medium_import_history" do
    field :medium_id, :string
  end

  @doc false
  def changeset(tag, attrs \\ %{}) do
    tag
    |> cast(attrs, [:medium_id])
    |> validate_required([:medium_id])
  end
end
