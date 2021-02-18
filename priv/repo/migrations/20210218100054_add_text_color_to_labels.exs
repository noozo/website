defmodule Noozo.Repo.Migrations.AddTextColorToLabels do
  use Ecto.Migration

  def change do
    alter table(:labels) do
      add :text_color_hex, :string, null: false, default: "#000000"
    end
  end
end
