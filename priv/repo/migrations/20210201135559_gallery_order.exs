defmodule Noozo.Repo.Migrations.GalleryOrder do
  use Ecto.Migration

  def change do
    alter table("gallery_images") do
      add :order, :integer
    end
  end
end
