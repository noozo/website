defmodule Noozo.Analytics.Worker do
  @moduledoc """
  Analytics worker
  """
  use GenServer, restart: :temporary

  import Ecto.Query, warn: false

  alias Noozo.Analytics.Metric
  alias Noozo.Repo

  @registry Noozo.Analytics.Registry

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: {:via, Registry, {@registry, path}})
  end

  @impl true
  def init(path) do
    Process.flag(:trap_exit, true)
    {:ok, {path, _counter = 0, _post = nil}}
  end

  @impl true
  def handle_info({:bump, post}, {path, 0, _}) do
    schedule_upsert()
    {:noreply, {path, 1, post}}
  end

  @impl true
  def handle_info({:bump, post}, {path, counter, _}) do
    {:noreply, {path, counter + 1, post}}
  end

  @impl true
  def handle_info(:upsert, {path, counter, post}) do
    upsert!(path, counter, post)
    {:noreply, {path, 0, post}}
  end

  defp schedule_upsert do
    Process.send_after(self(), :upsert, Enum.random(10..20) * 1_000)
  end

  def upsert!(path, counter, post) do
    date = Date.utc_today()

    query =
      from(
        _m in Metric,
        update: [inc: [counter: ^counter]]
      )

    post_id = if post, do: post.id, else: nil

    Repo.insert!(
      %Metric{date: date, path: path, counter: counter, post_id: post_id},
      on_conflict: query,
      conflict_target: [:date, :path]
    )
  end

  @impl true
  def terminate(_, {_path, 0, _post}), do: :ok
  def terminate(_, {path, counter, post}), do: upsert!(path, counter, post)
end
