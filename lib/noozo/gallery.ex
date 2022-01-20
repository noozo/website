defmodule Noozo.Gallery do
  @moduledoc """
  The Gallery context.
  """
  import Ecto.Query, warn: false

  alias Noozo.Gallery.Image
  alias Noozo.Repo

  require Logger

  @topic "gallery"

  def list do
    query =
      from(
        i in Image,
        order_by: [desc: :order, desc: :inserted_at]
      )

    Repo.all(query)
  end

  def list(params) do
    query =
      from(
        i in Image,
        order_by: [desc: :order, desc: :inserted_at]
      )

    Repo.paginate(query, params)
  end

  def get_image!(uuid) do
    Repo.get!(Image, uuid)
  end

  def create_image(attrs) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:image_created)
  end

  @impl true
  def update_image(%Image{} = image, attrs, before_save_func \\ & &1) do
    image
    |> Image.changeset(before_save(attrs, before_save_func))
    |> Repo.update()
    |> broadcast(:image_updated)
  end

  defp before_save(%{} = attrs, func) do
    func.(attrs)
  end

  ################### BROADCASTING ####################

  def subscribe do
    Phoenix.PubSub.subscribe(Noozo.PubSub, @topic)
  end

  def subscribe(uuid) do
    Phoenix.PubSub.subscribe(Noozo.PubSub, @topic <> "#{uuid}")
  end

  defp broadcast({:ok, object} = result, event) do
    Phoenix.PubSub.broadcast!(Noozo.PubSub, @topic, {event, object})

    Phoenix.PubSub.broadcast(
      Noozo.PubSub,
      @topic <> "#{object.uuid}",
      {event, object}
    )

    result
  end

  defp broadcast({:error, changeset}, _event),
    do: {:error, Repo.errors_from_changeset(changeset)}
end
