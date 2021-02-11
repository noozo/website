defmodule Noozo.Repo.Migrations.SetupStructure do
  use Ecto.Migration

  def change do
    create_if_not_exists table("pages") do
      add :title, :string, null: false
      add :content, :text, null: false
      add :slug, :string, null: false

      timestamps()
    end

    create_if_not_exists index("pages", [:slug])

    create_if_not_exists table("posts") do
      add :title, :string, null: false
      add :content, :text, null: false
      add :published_at, :utc_datetime, null: false
      add :slug, :string, null: false
      add :status, :string, null: false, default: "draft"

      timestamps()
    end

    create_if_not_exists index("posts", [:slug])
    create_if_not_exists index("posts", [:status])
    create_if_not_exists index("posts", [:published_at])

    create_if_not_exists table("taggings") do
      add :tag_id, :integer
      add :taggable_type, :string
      add :taggable_id, :integer
      add :tagger_type, :string
      add :tagger_id, :integer
      add :context, :string, size: 128

      timestamps()
    end

    create_if_not_exists index("taggings", [:context])
    create_if_not_exists index("taggings", [:tag_id])

    create_if_not_exists unique_index("taggings", [
                           :tag_id,
                           :taggable_id,
                           :taggable_type,
                           :context,
                           :tagger_id,
                           :tagger_type
                         ])

    create_if_not_exists index("taggings", [:taggable_id, :taggable_type, :context])

    create_if_not_exists index("taggings", [
                           :taggable_id,
                           :taggable_type,
                           :tagger_id,
                           :context
                         ])

    create_if_not_exists index("taggings", [:taggable_id])
    create_if_not_exists index("taggings", [:taggable_type])
    create_if_not_exists index("taggings", [:tagger_id, :tagger_type])
    create_if_not_exists index("taggings", [:tagger_id])

    create_if_not_exists table("tags") do
      add :name, :string, null: false
      add :taggings_count, :integer, default: 0

      timestamps()
    end

    create_if_not_exists unique_index("tags", [:name])

    create_if_not_exists table("users") do
      add :email, :string, default: "", null: false
      add :encrypted_password, :string, default: "", null: false
      add :reset_password_token, :string, null: true
      add :reset_password_sent_at, :utc_datetime, null: true
      add :remember_created_at, :utc_datetime, null: true

      timestamps()
    end

    create_if_not_exists unique_index("users", [:email])
    create_if_not_exists unique_index("users", [:reset_password_token])

    create_if_not_exists table("videos") do
      add :video_id, :string, null: false
      add :title, :string, null: false
      add :thumbnail_url, :string, null: false
      add :site, :string, null: false, default: "youtube"
      add :link, :string, null: false

      timestamps()
    end
  end
end
