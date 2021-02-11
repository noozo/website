defmodule Noozo.Analytics do
  @moduledoc """
  The Analytics context.
  """
  use Supervisor

  import Ecto.Query, warn: false

  alias Noozo.Analytics.Metric
  alias Noozo.Core.Post
  alias Noozo.Repo

  @worker Noozo.Analytics.Worker
  @registry Noozo.Analytics.Registry
  @supervisor Noozo.Analytics.WorkerSupervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @registry},
      {DynamicSupervisor, name: @supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def bump(path, post) when is_binary(path) do
    # Ignore admin
    unless String.starts_with?(path, "/admin") do
      pid =
        case Registry.lookup(@registry, path) do
          [{pid, _}] ->
            pid

          [] ->
            start_bump_worker(path)
        end

      send(pid, {:bump, post})
    end
  end

  defp start_bump_worker(path) do
    case DynamicSupervisor.start_child(@supervisor, {@worker, path}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def paginated_entries(start_date, end_date, params) do
    query =
      from e in Metric,
        where: e.date >= ^start_date and e.date < ^end_date,
        group_by: :path,
        select: %{
          counter: sum(e.counter),
          path: e.path
        },
        order_by: [desc: sum(e.counter)]

    Repo.paginate(query, params)
  end

  def list_entries(start_date, end_date, path) do
    conditions = dynamic([e], e.date >= ^start_date)
    conditions = dynamic([e], e.date < ^end_date and ^conditions)

    conditions =
      if path && path != "" do
        dynamic([e], e.path == ^path and ^conditions)
      else
        conditions
      end

    Repo.all(
      from e in Metric,
        where: ^conditions
    )
  end

  def count_entries(start_date, end_date, path) do
    conditions = dynamic([e], e.date >= ^start_date)
    conditions = dynamic([e], e.date < ^end_date and ^conditions)

    conditions =
      if path && path != "" do
        dynamic([e], e.path == ^path and ^conditions)
      else
        conditions
      end

    query =
      from e in Metric,
        where: ^conditions,
        select: %{
          count: sum(e.counter)
        }

    Repo.one(query).count
  end

  def list_popular_posts_since_days(days) do
    start_date = Timex.subtract(Timex.now(), Timex.Duration.from_days(days))
    end_date = Timex.add(Timex.now(), Timex.Duration.from_days(1))

    query =
      from e in Metric,
        where: e.date >= ^start_date and e.date < ^end_date,
        join: p in Post,
        on: e.post_id == p.id,
        group_by: [e.path, p.id, p.slug, p.title],
        select: %{
          post_id: p.id,
          post_slug: p.slug,
          post_title: p.title
        },
        order_by: [desc: sum(e.counter)]

    Repo.paginate(query, %{page: 1, page_size: 5}).entries
  end
end
