defmodule Noozo.Repo.Migrations.CreateFinancials do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:bank_account_movements) do
      add :date, :date, null: false
      add :description, :string
      add :debit, :integer
      add :credit, :integer
      add :balance, :integer
      add :category, :string

      timestamps()
    end

    create_if_not_exists index("bank_account_movements", [:date])

    create_if_not_exists unique_index("bank_account_movements", [:date, :debit, :credit, :balance])
  end
end
