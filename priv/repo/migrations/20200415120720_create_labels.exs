defmodule Noozo.Repo.Migrations.CreateLabels do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:labels) do
      add :title, :string, null: true
      add :color_hex, :string, null: false
      timestamps()
    end

    alter table(:items) do
      add :label_id, references(:labels)
    end
  end
end
