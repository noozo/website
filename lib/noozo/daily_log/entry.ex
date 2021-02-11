defimpl Phoenix.Param, for: Noozo.DailyLog.Entry do
  def to_param(%{date: date}) do
    "#{date}"
  end
end

defmodule Noozo.DailyLog.Entry do
  @moduledoc """
  A Daily log entry
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:date, :date, []}

  schema "daily_log" do
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:date, :content])
    |> validate_required([:date])
  end
end
