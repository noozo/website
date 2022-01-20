defmodule NoozoWeb.Admin.Cvs.Children.HeaderItemsView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Cvs
  alias Noozo.Cvs.CvHeaderItem

  alias NoozoWeb.Admin.Cvs.Children.Components.{ExpandCollapse, HeaderItem}

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-6" x-data="{collapsed: true}">
      <div class="text-lg mb-4 cursor-pointer" @click="collapsed = !collapsed">
        <%= live_component ExpandCollapse, var: "collapsed" %>
        Header Items
      </div>

      <a class="btn cursor-pointer mb-6" phx-click="add-item"
         :class="{'hidden': collapsed, 'visible': !collapsed}">
        Add Header Item
      </a>

      <div class="mt-6" :class="{'hidden': collapsed, 'visible': !collapsed}">
        <%= for item <- @items do %>
          <div class="flex">
            <div class="flex-col">
              <%= live_component HeaderItem, id: "header_item_#{item.uuid}", item: item %>
            </div>
            <a class="btn cursor-pointer flex-col h-10"
               phx-click="remove-item"
               phx-value-item_uuid={item.uuid}
               data-confirm="Are you sure you want to delete this item?">X</a>
            <a class="btn cursor-pointer flex-col h-10"
               phx-click="move-item-up"
               phx-value-item_uuid={item.uuid}>Up</a>
            <a class="btn cursor-pointer flex-col h-10"
               phx-click="move-item-down"
               phx-value-item_uuid={item.uuid}>Down</a>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, %{"cv_uuid" => cv_uuid} = _session, socket) do
    Cvs.subscribe()
    items = Cvs.get_header_items!(cv_uuid)
    {:ok, assign(socket, %{cv_uuid: cv_uuid, items: items})}
  end

  @impl true
  def handle_event("add-item", _event, socket) do
    {:ok, item} = Cvs.create_header_item(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :items, socket.assigns.items ++ [item])}
  end

  @impl true
  def handle_event("remove-item", %{"item_uuid" => item_uuid} = _event, socket) do
    {:ok, _item} = Cvs.delete_header_item(item_uuid)
    items = Enum.reject(socket.assigns.items, &(&1.uuid == item_uuid))
    {:noreply, assign(socket, :items, items)}
  end

  @impl true
  def handle_event("move-item-up", %{"item_uuid" => item_uuid} = _event, socket) do
    :ok = Cvs.move_item_up!(CvHeaderItem, item_uuid, &Cvs.update_header_item/2)
    items = Cvs.get_header_items!(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :items, items)}
  end

  @impl true
  def handle_event("move-item-down", %{"item_uuid" => item_uuid} = _event, socket) do
    :ok = Cvs.move_item_down!(CvHeaderItem, item_uuid, &Cvs.update_header_item/2)
    items = Cvs.get_header_items!(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :items, items)}
  end

  @impl true
  def handle_info({event, _cv}, socket) do
    Logger.debug("HeaderItemsView - Unhandled event: #{event}")
    {:noreply, socket}
  end
end
