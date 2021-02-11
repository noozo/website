defmodule Noozo.Repo.Migrations.CreateListsAndItems do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:lists, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :board_id, references(:boards, on_delete: :delete_all, type: :uuid)
      timestamps()
    end

    create_if_not_exists index("lists", [:id])
    create_if_not_exists index("lists", [:board_id])

    create_if_not_exists table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :list_id, references(:lists, on_delete: :delete_all, type: :uuid)
      timestamps()
    end

    create_if_not_exists index("items", [:id])
    create_if_not_exists index("items", [:list_id])
  end
end
