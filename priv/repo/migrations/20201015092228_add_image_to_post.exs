defmodule Noozo.Repo.Migrations.AddImageToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :image, :bytea
      add :image_type, :string
    end
  end
end
