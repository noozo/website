defmodule NoozoWeb.Admin.Cvs.Children.SectionsView do
  use Phoenix.LiveView

  alias Noozo.Cvs

  alias NoozoWeb.Admin.Cvs.Children.Components.ExpandCollapse
  alias NoozoWeb.Admin.Cvs.Children.Components.SectionItems

  require Logger

  def render(assigns) do
    ~L"""
    <div class="mt-6" x-data="{collapsed: false}">
      <div class="text-lg mb-4 cursor-pointer" @click="collapsed = !collapsed">
        <%= live_component @socket, ExpandCollapse, var: "collapsed" %>
        Sections
      </div>

      <a class="btn cursor-pointer" phx-click="add-section"
         :class="{'hidden': collapsed, 'visible': !collapsed}">
        Add Section
      </a>

      <div class="mt-6" :class="{'hidden': collapsed, 'visible': !collapsed}">
        <%= for section <- @sections do %>
          <div id="section_container_<%= section.uuid %>">
            <div class="mb-6" x-data="{sectionCollapsed: true}">
              <div class="flex">
                <div @click="sectionCollapsed = !sectionCollapsed">
                  <%= live_component @socket, ExpandCollapse, var: "sectionCollapsed" %>
                </div>
                <form phx-change="update-section" phx-debounce="500">
                  <input type="hidden" name="section_uuid" value="<%= section.uuid %>" />
                  <input class='mr-4 flex-col shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md'
                         type='text' name='title' phx-debounce="500" value='<%= section.title %>' />
                </form>
                <a class="btn cursor-pointer flex-col"
                   phx-click="remove-section" phx-value-section_uuid="<%= section.uuid %>">X</a>
              </div>

              <div class="mt-2 ml-4" :class="{'hidden': sectionCollapsed, 'visible': !sectionCollapsed}">
                <%= live_component @socket, SectionItems, id: "cv_section_items_#{section.uuid}", section_uuid: section.uuid %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, %{"cv_uuid" => cv_uuid} = _session, socket) do
    sections = Cvs.get_sections!(cv_uuid)
    {:ok, assign(socket, %{cv_uuid: cv_uuid, sections: sections})}
  end

  def handle_event("add-section", _event, socket) do
    {:ok, section} = Cvs.create_section(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :sections, socket.assigns.sections ++ [section])}
  end

  def handle_event(
        "update-section",
        %{"section_uuid" => section_uuid, "title" => title} = _event,
        socket
      ) do
    {:ok, section} = Cvs.update_section(section_uuid, %{title: title})
    {:noreply, assign(socket, :section, section)}
  end

  def handle_event("remove-section", %{"section_uuid" => section_uuid} = _event, socket) do
    {:ok, _section} = Cvs.delete_section(section_uuid)
    sections = Enum.reject(socket.assigns.sections, &(&1.uuid == section_uuid))
    {:noreply, assign(socket, :sections, sections)}
  end

  def handle_info({event, _cv}, socket) do
    Logger.debug("Sections - Unhandled event: #{event}")
    {:noreply, socket}
  end
end
