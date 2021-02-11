defmodule Noozo.Cvs.Cv do
  @moduledoc """
  A CV
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Accounts.User
  alias Noozo.Cvs.{CvHeaderItem, CvSection}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "cvs" do
    field :title, :string

    belongs_to :user, User, foreign_key: :user_id, references: :id, type: :integer
    has_many :header_items, CvHeaderItem
    has_many :sections, CvSection

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:title, :uuid, :user_id])
    |> validate_required([])
  end
end
