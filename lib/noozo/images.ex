defmodule Noozo.Images do
  @moduledoc """
  The Image cache context.
  """
  import Ecto.Query, warn: false

  alias Noozo.Images.Entry
  alias Noozo.Repo

  require Logger

  def get(key) do
    Repo.get(Entry, key)
  end

  def create({_key, nil}) do
    {:error, :badarg}
  end

  # sobelow_skip ["Traversal.FileModule"]
  def create({key, binary}) do
    path = Path.join(:code.priv_dir(:noozo), "static/images/cache/")
    :ok = File.mkdir_p(path)
    :ok = File.write!("#{path}/#{key}", binary)

    %Entry{}
    |> Entry.changeset(%{
      key: key,
      path: "/images/cache/#{key}"
    })
    |> Repo.insert(on_conflict: {:replace, [:path]}, conflict_target: [:key])
  end
end
