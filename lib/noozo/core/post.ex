defmodule Noozo.Core.Post do
  @moduledoc """
    A post
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Noozo.Core.{PostLike, Tagging}
  alias Noozo.Images

  @image_prefix "post"

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_at, :utc_datetime
    field :slug, :string
    field :status, :string
    field :like_count, :integer
    field :image, :binary
    field :image_type, :string
    has_many :taggings, {"taggings", Tagging}, foreign_key: :taggable_id
    has_many :tags, through: [:taggings, :tag]
    has_many :post_likes, {"post_likes", PostLike}, foreign_key: :post_id

    # belongs_to :user, Noozo.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [
      :title,
      :content,
      :published_at,
      :slug,
      :status,
      :like_count,
      :image,
      :image_type
    ])
    |> validate_required([:title, :published_at, :slug])
  end

  @doc false
  def image_data_for_disk(post) do
    {"#{@image_prefix}_#{post.id}", post.image}
  end

  @doc false
  def image_url(post) do
    case Images.get("#{@image_prefix}_#{post.id}") do
      nil ->
        {:ok, image} = Images.create(image_data_for_disk(post))
        image.path

      image ->
        image.path
    end
  end
end
