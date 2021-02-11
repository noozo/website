defmodule Noozo.Cvs.CvSectionItem do
  @moduledoc """
  A CV section item
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Cvs.CvSection
  alias Noozo.Images

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @image_prefix "cv_section_item"

  schema "cv_section_items" do
    field :image, :binary
    field :image_type, :string
    field :date_from, :date
    field :date_to, :date
    field :title, :string
    field :subtitle, :string
    field :content, :string
    field :footer, :string

    belongs_to :section, CvSection,
      foreign_key: :cv_section_uuid,
      references: :uuid,
      type: Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :uuid,
      :cv_section_uuid,
      :image,
      :image_type,
      :date_from,
      :date_to,
      :title,
      :subtitle,
      :content,
      :footer
    ])
    |> validate_required([:content, :cv_section_uuid])
  end

  @doc false
  def image_data_for_disk(item) do
    {"#{@image_prefix}_#{item.uuid}", item.image}
  end

  @doc false
  def image_url(item) do
    case Images.get("#{@image_prefix}_#{item.uuid}") do
      nil ->
        {:ok, image} = Images.create(image_data_for_disk(item))
        image.path

      image ->
        image.path
    end
  end
end
