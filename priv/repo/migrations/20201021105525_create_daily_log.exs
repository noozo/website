defmodule Noozo.Repo.Migrations.CreateDailyLog do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:daily_log, primary_key: false) do
      add :date, :date, primary_key: true
      add :content, :text, null: true
      timestamps()
    end

    create_if_not_exists index("daily_log", [:date])
  end
end
