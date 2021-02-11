defmodule Noozo.Core.Tagging do
  @moduledoc """
    Represents the tagging of a particular model with a given tag
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Noozo.Core.Post
  alias Noozo.Core.Tag

  schema "taggings" do
    field :tag_id, :integer
    field :taggable_type, :string, default: "Post"
    field :taggable_id, :integer
    field :tagger_type, :string
    field :tagger_id, :integer
    field :context, :string, default: "tags"

    has_one :tag, {"tags", Tag}, foreign_key: :id, references: :tag_id
    has_one :post, {"posts", Post}, foreign_key: :id, references: :taggable_id

    timestamps(type: :utc_datetime, inserted_at: :created_at, updated_at: false)
  end

  @doc false
  def changeset(tagging, attrs \\ %{}) do
    tagging
    |> cast(attrs, [
      :tag_id,
      :taggable_type,
      :taggable_id,
      :tagger_type,
      :tagger_id,
      :context
    ])
    |> validate_required([:tag_id, :taggable_type, :taggable_id])
  end
end
