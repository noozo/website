defmodule Noozo.MediumCom.ImportServer do
  @moduledoc """
  GenServer to periodically retrieve my posts from medium.com
  """
  use GenServer
  require Logger

  alias Noozo.MediumCom.Importer

  @me __MODULE__

  def start_link(opts) do
    {:ok, pid} = result = GenServer.start_link(@me, opts, name: @me)
    Logger.debug("#{@me} GenServer started with# #{inspect(pid)}.")
    result
  end

  @impl true
  def init(username: username, interval: interval) do
    send(self(), :import)
    {:ok, %{username: username, interval: interval}}
  end

  @impl true
  def handle_info(:import, state) do
    Importer.import(state.username)
    Process.send_after(self(), :import, state.interval)
    {:noreply, state}
  end
end
