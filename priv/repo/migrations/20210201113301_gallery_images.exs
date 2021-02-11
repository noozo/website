defmodule Noozo.Repo.Migrations.GalleryImages do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:gallery_images, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :title, :string, null: false
      add :image, :bytea
      add :image_type, :string

      timestamps()
    end
  end
end
