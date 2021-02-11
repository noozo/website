defmodule Noozo.Cvs.CvSection do
  @moduledoc """
  A CV section
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Cvs.{Cv, CvSectionItem}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "cv_sections" do
    field :title, :string

    belongs_to :cv, Cv, foreign_key: :cv_uuid, references: :uuid, type: Ecto.UUID
    has_many :items, CvSectionItem

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:title, :uuid, :cv_uuid])
    |> validate_required([:title, :cv_uuid])
  end
end
