defmodule Noozo.Repo.Migrations.Add2faSecretToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:secret_2fa, :binary)
    end
  end
end
