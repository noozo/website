defmodule Noozo.Repo.Migrations.AddCacheInfoToImages do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:images, primary_key: false) do
      add :key, :string, primary_key: true
      add :path, :string, null: false

      timestamps()
    end
  end
end
