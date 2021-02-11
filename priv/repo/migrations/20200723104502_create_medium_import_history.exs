defmodule Noozo.Repo.Migrations.CreateMediumImportHistory do
  use Ecto.Migration

  def change do
    create table(:medium_import_history) do
      add :medium_id, :string, null: false
    end

    create_if_not_exists index("medium_import_history", [:medium_id])
  end
end
