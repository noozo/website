defmodule Noozo.Repo.Migrations.CreateTodoStructure do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:boards, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      timestamps()
    end

    create_if_not_exists index("boards", [:id])
  end
end
