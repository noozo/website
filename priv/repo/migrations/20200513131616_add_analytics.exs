defmodule Noozo.Repo.Migrations.AddAnalytics do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:analytics_entries) do
      add :relative_url, :string, null: false
      timestamps()
    end

    create_if_not_exists index("analytics_entries", [:relative_url])
  end
end
