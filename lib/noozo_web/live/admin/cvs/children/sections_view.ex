defmodule NoozoWeb.Admin.Cvs.Children.SectionsView do
  use NoozoWeb, :surface_view

  alias Noozo.Cvs
  alias Noozo.Cvs.CvSection

  alias NoozoWeb.Admin.Cvs.Children.Components.ExpandCollapse
  alias NoozoWeb.Admin.Cvs.Children.Components.SectionItems

  require Logger

  @impl true
  def render(assigns) do
    ~F"""
    <div class="mt-6" x-data="{collapsed: false}">
      <div class="text-lg mb-4 cursor-pointer" @click="collapsed = !collapsed">
        <ExpandCollapse var="collapsed" />
        Sections
      </div>

      <a
        class="btn cursor-pointer"
        phx-click="add-section"
        :class="{'hidden': collapsed, 'visible': !collapsed}"
      >
        Add Section
      </a>

      <div class="mt-6" :class="{'hidden': collapsed, 'visible': !collapsed}">
        {#for section <- @sections}
          <div id={"section_container_#{section.uuid}"}>
            <div class="mb-6" x-data="{sectionCollapsed: true}">
              <div class="flex">
                <div @click="sectionCollapsed = !sectionCollapsed">
                  <ExpandCollapse var="sectionCollapsed" />
                </div>
                <form phx-change="update-section" phx-debounce="500">
                  <input type="hidden" name="section_uuid" value={section.uuid}>
                  <input class="mr-4 flex-col" type="text" name="title" phx-debounce="500" value={section.title}>
                </form>
                <a
                  class="btn cursor-pointer flex-col"
                  phx-click="remove-section"
                  phx-value-section_uuid={section.uuid}
                  data-confirm="Are you sure you want to delete this section?"
                >X</a>
                <a
                  class="btn cursor-pointer flex-col h-10"
                  phx-click="move-section-up"
                  phx-value-section_uuid={section.uuid}
                >Up</a>
                <a
                  class="btn cursor-pointer flex-col h-10"
                  phx-click="move-section-down"
                  phx-value-section_uuid={section.uuid}
                >Down</a>
              </div>

              <div class="mt-2 ml-4" :class="{'hidden': sectionCollapsed, 'visible': !sectionCollapsed}">
                <SectionItems id={"cv_section_items_#{section.uuid}"} section_uuid={section.uuid} />
              </div>
            </div>
          </div>
        {/for}
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, %{"cv_uuid" => cv_uuid} = _session, socket) do
    sections = Cvs.get_sections!(cv_uuid)
    {:ok, assign(socket, %{cv_uuid: cv_uuid, sections: sections})}
  end

  @impl true
  def handle_event("add-section", _event, socket) do
    {:ok, section} = Cvs.create_section(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :sections, socket.assigns.sections ++ [section])}
  end

  @impl true
  def handle_event(
        "update-section",
        %{"section_uuid" => section_uuid, "title" => title} = _event,
        socket
      ) do
    {:ok, section} = Cvs.update_section(section_uuid, %{title: title})
    {:noreply, assign(socket, :section, section)}
  end

  @impl true
  def handle_event("remove-section", %{"section_uuid" => section_uuid} = _event, socket) do
    {:ok, _section} = Cvs.delete_section(section_uuid)
    sections = Enum.reject(socket.assigns.sections, &(&1.uuid == section_uuid))
    {:noreply, assign(socket, :sections, sections)}
  end

  @impl true
  def handle_event("move-section-up", %{"section_uuid" => section_uuid} = _event, socket) do
    :ok = Cvs.move_item_up!(CvSection, section_uuid, &Cvs.update_section/2)
    sections = Cvs.get_sections!(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :sections, sections)}
  end

  @impl true
  def handle_event("move-section-down", %{"section_uuid" => section_uuid} = _event, socket) do
    :ok = Cvs.move_item_down!(CvSection, section_uuid, &Cvs.update_section/2)
    sections = Cvs.get_sections!(socket.assigns.cv_uuid)
    {:noreply, assign(socket, :sections, sections)}
  end

  @impl true
  def handle_info({event, _cv}, socket) do
    Logger.debug("Sections - Unhandled event: #{event}")
    {:noreply, socket}
  end
end
