defmodule Noozo.Finance do
  @moduledoc """
  The Finance context.
  """
  import Ecto.Query, warn: false

  alias Noozo.Finance.BankAccountMovement
  alias Noozo.Repo

  def list_bank_account_movements(params, paginate \\ true) do
    start_date = params["start_date"]
    end_date = params["end_date"]

    query =
      from(
        m in BankAccountMovement,
        where: m.date >= ^start_date and m.date <= ^end_date,
        order_by: [desc: :date]
      )

    if paginate do
      Repo.paginate(query, params)
    else
      Repo.all(query)
    end
  end

  def get_debit_credits(params) do
    start_date = params["start_date"]
    end_date = params["end_date"]

    query =
      from m in BankAccountMovement,
        where: m.date >= ^start_date and m.date <= ^end_date,
        select: {fragment("SUM(debit) as debits"), fragment("SUM(credit) as credits")}

    Repo.one(query)
  end

  def create_bank_account_movements(maps) do
    Repo.insert_all(
      BankAccountMovement,
      maps,
      on_conflict: :replace_all,
      conflict_target: [:date, :debit, :credit, :balance]
    )
  end
end
