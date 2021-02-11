defmodule Noozo.Repo.Migrations.AddPostToMetrics do
  use Ecto.Migration

  def change do
    alter table(:metrics) do
      add :post_id, :integer
    end
  end
end
