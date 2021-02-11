defmodule Noozo.Repo.Migrations.AddOrderToLists do
  use Ecto.Migration

  def change do
    alter table("lists") do
      add :order, :integer
    end
  end
end
