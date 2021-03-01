defmodule Noozo.Repo.Migrations.AddHas2faToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:has_2fa, :boolean, default: false)
    end
  end
end
