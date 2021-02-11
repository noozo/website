defmodule Noozo.Cvs do
  @moduledoc """
  The CV context.
  """
  import Ecto.Query, warn: false

  alias Noozo.Cvs.{Cv, CvHeaderItem, CvSection, CvSectionItem}
  alias Noozo.Repo

  require Logger

  @topic "cvs"

  def list_cvs(params) do
    query =
      from(c in Cv,
        preload: [:user]
      )

    Repo.paginate(query, params)
  end

  def create_cv(attributes) do
    %Cv{}
    |> Cv.changeset(attributes)
    |> Repo.insert()
    |> broadcast(:created)
  end

  def get_cv!(uuid) do
    Cv
    |> Repo.get!(uuid)
    |> Repo.preload(:user)
  end

  def get_full_cv!(uuid) do
    Cv
    |> Repo.get!(uuid)
    |> Repo.preload(:user)
    |> preload_cv()
  end

  def get_user_cv!(user_id) do
    [cv | _rest] =
      Repo.all(
        from cv in Cv,
          where: cv.user_id == ^user_id
      )

    preload_cv(cv)
  end

  defp preload_cv(cv) do
    section_items_query =
      from(
        si in CvSectionItem,
        order_by: [asc: si.inserted_at]
      )

    cv
    |> Repo.preload([
      :user,
      header_items:
        from(
          hi in CvHeaderItem,
          order_by: [asc: hi.inserted_at]
        ),
      sections:
        from(
          s in CvSection,
          preload: [items: ^section_items_query],
          order_by: [asc: s.inserted_at]
        )
    ])
  end

  def get_header_items!(cv_uuid) do
    Repo.all(
      from(
        i in CvHeaderItem,
        where: i.cv_uuid == ^cv_uuid,
        order_by: [asc: i.inserted_at]
      )
    )
  end

  def get_sections!(cv_uuid) do
    Repo.all(
      from(
        s in CvSection,
        where: s.cv_uuid == ^cv_uuid,
        preload: [
          items:
            ^from(
              i in CvSectionItem,
              order_by: [asc: i.inserted_at]
            )
        ],
        order_by: [asc: s.inserted_at]
      )
    )
  end

  def update_cv(%Cv{} = cv, attrs) do
    cv
    |> Cv.changeset(attrs)
    |> Repo.update()
    |> broadcast(:updated)
  end

  def get_header_item!(uuid) do
    CvHeaderItem
    |> Repo.get!(uuid)
  end

  def create_header_item(cv_uuid) do
    %CvHeaderItem{}
    |> CvHeaderItem.changeset(%{cv_uuid: cv_uuid, content: "A new header item appears"})
    |> Repo.insert()
    |> broadcast(:header_item_created)
  end

  def update_header_item(item, attrs) do
    item
    |> CvHeaderItem.changeset(attrs)
    |> Repo.update()
    |> broadcast(:header_item_updated)
  end

  def delete_header_item(item_uuid) do
    item_uuid
    |> get_header_item!()
    |> Repo.delete()
    |> broadcast(:header_item_deleted)
  end

  def get_section!(uuid) do
    CvSection
    |> Repo.get!(uuid)
    |> Repo.preload(
      items:
        from(
          si in CvSectionItem,
          order_by: [asc: si.inserted_at]
        )
    )
  end

  def create_section(cv_uuid) do
    with {:ok, section} <-
           %CvSection{}
           |> CvSection.changeset(%{cv_uuid: cv_uuid, title: "A new section appears"})
           |> Repo.insert()
           |> broadcast(:section_created) do
      {:ok, Map.put(section, :items, [])}
    end
  end

  def update_section(section_uuid, attrs) do
    section_uuid
    |> get_section!()
    |> CvSection.changeset(attrs)
    |> Repo.update()
    |> broadcast(:section_updated)
  end

  def delete_section(section_uuid) do
    section_uuid
    |> get_section!()
    |> Repo.delete()
    |> broadcast(:section_deleted)
  end

  def list_section_items do
    Repo.all(from(c in CvSectionItem))
  end

  def get_section_item!(uuid) do
    CvSectionItem
    |> Repo.get!(uuid)
  end

  def create_section_item(section_uuid) do
    %CvSectionItem{}
    |> CvSectionItem.changeset(%{
      cv_section_uuid: section_uuid,
      content: "A new section item appears"
    })
    |> Repo.insert()
    |> broadcast(:section_item_created)
  end

  def update_section_item(cv_section_item, attrs, before_save_func \\ & &1) do
    cv_section_item
    |> CvSectionItem.changeset(before_save(attrs, before_save_func))
    |> Repo.update()
    |> broadcast(:section_item_updated)
  end

  defp before_save(%{} = attrs, func) do
    func.(attrs)
  end

  def delete_section_item(item_uuid) do
    item_uuid
    |> get_section_item!()
    |> Repo.delete()
    |> broadcast(:section_item_deleted)
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
