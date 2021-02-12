defmodule Noozo.Repo.Migrations.AddOrderToCvs do
  use Ecto.Migration

  def change do
    alter table(:cv_header_items) do
      add :order, :integer
    end
    alter table(:cv_sections) do
      add :order, :integer
    end
    alter table(:cv_section_items) do
      add :order, :integer
    end
  end
end
