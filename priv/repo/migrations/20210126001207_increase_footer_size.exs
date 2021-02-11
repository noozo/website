defmodule Noozo.Repo.Migrations.IncreaseFooterSize do
  use Ecto.Migration

  def change do
    alter table(:cv_section_items) do
      modify :footer, :text, null: true
    end
  end
end
