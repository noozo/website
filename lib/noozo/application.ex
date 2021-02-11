defmodule Noozo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # sobelow_skip ["Traversal.FileModule"]
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Noozo.Repo,
      # Telemetry data
      NoozoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Noozo.PubSub},
      # Analytics
      Noozo.Analytics,
      # Start the endpoint when the application starts
      {SiteEncrypt.Phoenix, NoozoWeb.Endpoint}
      # Starts a worker by calling: Noozo.Worker.start_link(arg)
      # {Noozo.Worker, arg},
      # Genserver to periodically fetch posts from medium.com
      # {Noozo.MediumCom.ImportServer, username: "@noozo", interval: 3600000}
    ]

    :memory_cache = :ets.new(:memory_cache, [:set, :public, :named_table])
    {:ok, contents} = File.read(Path.join(:code.priv_dir(:noozo), "data/ignore_words.txt"))
    true = :ets.insert(:memory_cache, {"ignore_words", String.split(contents, "\n", trim: true)})

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Noozo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NoozoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
