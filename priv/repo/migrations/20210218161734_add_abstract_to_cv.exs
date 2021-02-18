defmodule Noozo.Repo.Migrations.AddAbstractToCV do
  use Ecto.Migration

  def change do
    alter table(:cvs) do
      add :abstract, :text
    end
  end
end
