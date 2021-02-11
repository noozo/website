defmodule Noozo.Repo.Migrations.CreateIndexOnLikes do
  use Ecto.Migration

  def change do
    create unique_index(
             :post_likes,
             [:ga_id, :post_id],
             name: :like_unique_per_post_and_user
           )
  end
end
