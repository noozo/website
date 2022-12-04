defmodule Noozo.DailyLog do
  @moduledoc """
  The DailyLog context.
  """
  import Ecto.Query, warn: false

  alias Noozo.DailyLog.Entry
  alias Noozo.Repo

  require Logger

  def list_entries do
    Entry |> Repo.all()
  end

  def list_entries(params) do
    query = from(p in Entry)

    query
    |> order_by(desc: :date)
    |> Repo.paginate(params)
  end

  def find_or_create(date) do
    {:ok, entry} =
      %Entry{}
      |> Entry.changeset(%{date: date})
      |> Repo.insert(on_conflict: :nothing)

    if is_nil(entry.content) do
      Repo.one(from e in Entry, where: e.date == ^entry.date)
    else
      entry
    end
  end

  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end
end
