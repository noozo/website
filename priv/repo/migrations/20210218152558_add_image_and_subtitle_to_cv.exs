defmodule Noozo.Repo.Migrations.AddImageAndSubtitleToCV do
  use Ecto.Migration

  def change do
    alter table(:cvs) do
      add :subtitle, :string
      add :image, :bytea
      add :image_type, :string
    end
  end
end
