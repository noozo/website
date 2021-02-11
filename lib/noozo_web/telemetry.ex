defmodule NoozoWeb.Telemetry do
  @moduledoc """
  Telemetry module
  """
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        tags: [:method, :request_path],
        tag_values: &tag_method_and_request_path/1,
        unit: {:native, :millisecond}
      ),
      counter("phoenix.endpoint.stop.duration",
        tags: [:method, :request_path],
        tag_values: &tag_method_and_request_path/1,
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("noozo.repo.query.total_time", unit: {:native, :millisecond}),
      summary("noozo.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("noozo.repo.query.query_time", unit: {:native, :millisecond}),
      summary("noozo.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("noozo.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {NoozoWeb, :count_users, []}
    ]
  end

  # Extracts labels like "GET /"
  defp tag_method_and_request_path(metadata) do
    Map.merge(metadata, Map.take(metadata.conn, [:method, :request_path]))
  end
end
