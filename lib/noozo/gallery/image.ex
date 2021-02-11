defmodule Noozo.Gallery.Image do
  @moduledoc """
  A gallery image
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Images

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @image_prefix "gallery_image"

  schema "gallery_images" do
    field :title, :string
    field :order, :integer
    field :image, :binary
    field :image_type, :string

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :uuid,
      :image,
      :image_type,
      :title,
      :order
    ])
    |> validate_required([:title])
  end

  @doc false
  def image_data_for_disk(image) do
    {"#{@image_prefix}_#{image.uuid}", image.image}
  end

  @doc false
  def image_url(image) do
    case Images.get("#{@image_prefix}_#{image.uuid}") do
      nil ->
        {:ok, image} = Images.create(image_data_for_disk(image))
        image.path

      image ->
        image.path
    end
  end
end
