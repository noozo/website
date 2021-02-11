defmodule Noozo.Repo.Migrations.AddLikeCountToPosts do
  use Ecto.Migration

  def change do
    create table(:post_likes) do
      add :post_id, references(:posts), null: false
      add :ga_id, :string, null: false

      timestamps()
    end

    alter table(:posts) do
      add :like_count, :integer, default: fragment("floor(random() * 100 + 1)::int"), null: false
    end
  end
end
