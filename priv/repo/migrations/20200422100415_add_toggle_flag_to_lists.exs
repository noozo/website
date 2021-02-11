defmodule Noozo.Repo.Migrations.AddToggleFlagToLists do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :open, :boolean, default: true
    end
  end
end
