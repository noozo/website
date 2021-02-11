defmodule Noozo.Core.PostLike do
  @moduledoc """
    A post
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Noozo.Core.Post

  schema "post_likes" do
    field :ga_id, :string
    belongs_to :posts, {"posts", Post}, foreign_key: :post_id

    timestamps()
  end

  @doc false
  def changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [:ga_id, :post_id])
    |> validate_required([:ga_id, :post_id])
    |> unique_constraint(
      :like_unique_per_post_and_user,
      name: :like_unique_per_post_and_user
    )
  end
end
