defmodule NoozoWeb.Admin.Cvs.Children.Components.SectionItems do
  @moduledoc """
  Section items component
  """
  use NoozoWeb, :surface_component

  alias Noozo.Cvs
  alias Noozo.Cvs.CvSectionItem

  alias NoozoWeb.Admin.Cvs.Children.SectionItemView

  require Logger

  prop section_uuid, :string, required: true
  data items, :list

  @impl true
  def update(%{id: id, section_uuid: section_uuid} = _assigns, socket) do
    section = Cvs.get_section!(section_uuid)
    {:ok, assign(socket, %{id: id, items: section.items, section_uuid: section_uuid})}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div id={@id} class="mt-6">
      <div class="text-lg mb-4 cursor-pointer">
        Items
      </div>

      <a class="btn cursor-pointer" phx-click="add-item" phx-target={@myself}>
        Add Item
      </a>

      <div class="mt-6">
        {#for item <- @items}
          <div class="flex">
            {live_render(@socket, SectionItemView,
              id: "section_item_#{item.uuid}",
              session: %{"item_uuid" => item.uuid}
            )}
            <a
              class="btn cursor-pointer flex-col h-10"
              phx-click="remove-item"
              phx-target={@myself}
              phx-value-item_uuid={item.uuid}
              data-confirm="Are you sure you want to delete this item?"
            >X</a>
            <a
              class="btn cursor-pointer flex-col h-10"
              phx-target={@myself}
              phx-click="move-item-up"
              phx-value-item_uuid={item.uuid}
            >Up</a>
            <a
              class="btn cursor-pointer flex-col h-10"
              phx-target={@myself}
              phx-click="move-item-down"
              phx-value-item_uuid={item.uuid}
            >Down</a>
          </div>
        {/for}
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add-item", _event, socket) do
    {:ok, item} = Cvs.create_section_item(socket.assigns.section_uuid)
    {:noreply, assign(socket, :items, socket.assigns.items ++ [item])}
  end

  @impl true
  def handle_event("remove-item", %{"item_uuid" => item_uuid} = _event, socket) do
    {:ok, _item} = Cvs.delete_section_item(item_uuid)
    items = Enum.reject(socket.assigns.items, &(&1.uuid == item_uuid))
    {:noreply, assign(socket, :items, items)}
  end

  @impl true
  def handle_event("move-item-up", %{"item_uuid" => item_uuid} = _event, socket) do
    :ok = Cvs.move_item_up!(CvSectionItem, item_uuid, &Cvs.update_section_item/2)
    section = Cvs.get_section!(socket.assigns.section_uuid)
    {:noreply, assign(socket, :items, section.items)}
  end

  @impl true
  def handle_event("move-item-down", %{"item_uuid" => item_uuid} = _event, socket) do
    :ok = Cvs.move_item_down!(CvSectionItem, item_uuid, &Cvs.update_section_item/2)
    section = Cvs.get_section!(socket.assigns.section_uuid)
    {:noreply, assign(socket, :items, section.items)}
  end
end
