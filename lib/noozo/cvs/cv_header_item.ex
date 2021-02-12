defmodule Noozo.Cvs.CvHeaderItem do
  @moduledoc """
  A CV header item
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Cvs.Cv

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "cv_header_items" do
    field :content, :string
    field :order, :integer

    belongs_to :cv, Cv, foreign_key: :cv_uuid, references: :uuid, type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:content, :uuid, :cv_uuid, :order])
    |> validate_required([:content, :cv_uuid])
  end
end
