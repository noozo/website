defmodule Noozo.Finance.BankAccountMovement do
  @moduledoc """
    A bank account movement entry
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "bank_account_movements" do
    field :date, :date
    field :description, :string
    field :debit, Money.Ecto.Amount.Type
    field :credit, Money.Ecto.Amount.Type
    field :balance, Money.Ecto.Amount.Type
    field :category, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [
      :date,
      :description,
      :debit,
      :credit,
      :balance,
      :category
    ])
    |> validate_required([:date, :balance])
  end
end
