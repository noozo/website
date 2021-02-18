defmodule Noozo.Cvs.Cv do
  @moduledoc """
  A CV
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Accounts.User
  alias Noozo.Cvs.{CvHeaderItem, CvSection}
  alias Noozo.Images

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @image_prefix "cv"

  schema "cvs" do
    field :title, :string
    field :subtitle, :string
    field :abstract, :string
    field :image, :binary
    field :image_type, :string

    belongs_to :user, User, foreign_key: :user_id, references: :id, type: :integer
    has_many :header_items, CvHeaderItem
    has_many :sections, CvSection

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:title, :subtitle, :abstract, :uuid, :user_id, :image, :image_type])
    |> validate_required([])
  end

  @doc false
  def image_data_for_disk(cv) do
    {"#{@image_prefix}_#{cv.uuid}", cv.image}
  end

  @doc false
  def image_url(cv) do
    case Images.get("#{@image_prefix}_#{cv.uuid}") do
      nil ->
        {:ok, image} = Images.create(image_data_for_disk(cv))
        image.path

      image ->
        image.path
    end
  end
end
