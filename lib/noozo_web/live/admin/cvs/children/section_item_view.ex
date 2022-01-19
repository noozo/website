defmodule NoozoWeb.Admin.Cvs.Children.SectionItemView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Cvs

  alias NoozoWeb.Admin.Cvs.Children.Components.ExpandCollapse

  def render(assigns) do
    ~L"""
      <div class="shadow p-2"
           :class="{'mb-2': collapsed, 'mb-6': !collapsed}"
           x-data="{collapsed: true}">
        <div class="text-lg cursor-pointer" @click="collapsed = !collapsed">
        <%= live_component ExpandCollapse, var: "collapsed" %>
        <span :class="{'visible': collapsed, 'hidden': !collapsed}" class="text-sm">
          <%= String.slice(@item.title || @item.content, 0..39) %>
        </span>
      </div>

      <form phx-change="save" phx-debounce="500"
            :class="{'hidden': collapsed, 'visible': !collapsed}">
        <div class="grid grid-cols-6 gap-4">
          <div class="col-span-3">
            <label for="date_from">From</label>
            <input class='datepicker'
                   type='date' name='date_from' phx-debounce="500" value='<%= @item.date_from %>' />
          </div>

          <div class="col-span-3">
            <label for="date_to">To</label>
            <input class='datepicker'
                   type='date' name='date_to' phx-debounce="500" value='<%= @item.date_to %>' />
          </div>

          <div class="col-span-6">
            <label for="title" class="mr-4 text-sm font-medium text-gray-700">Title</label>
            <div class="flex">
              <input class='flex-col mr-4'
                      type='text' name='title' phx-debounce="500" value='<%= @item.title %>' />
            </div>
          </div>

          <div class="col-span-6">
            <label for="subtitle">Subtitle</label>
            <input class='flex-col mr-4'
                   type='text' name='subtitle' phx-debounce="500" value='<%= @item.subtitle %>' />
          </div>

          <div class="col-span-6">
            <label for="content">Content</label>
            <textarea type='text' name='content' phx-debounce="500" rows="10"><%= @item.content %></textarea>
          </div>

          <div class="col-span-6">
            <label for="footer">Footer</label>
            <textarea type='text' name='footer' phx-debounce="500" rows="5"><%= @item.footer %></textarea>
          </div>
        </div>
      </form>

      <form phx-submit="upload" phx-change="validate"
          :class="{'hidden': collapsed, 'visible': !collapsed}">
        <div class="grid grid-cols-6 gap-4 mt-4">
          <label for="image">Image</label>

          <%= if @item.image do %>
            <div class="block mr-6" phx-click="remove-image" data-confirm="Remove image?">
              <%=
                data = Base.encode64(@item.image)
                Phoenix.HTML.raw(
                  "<img src=\"data:"<>@item.image_type<>";base64,"<>data<>"\" width=\"50px\">"
                )
              %>
            </div>
          <% end %>

          <div class="col-span-6">
            <%= for {_ref, msg} <- @uploads.image.errors do %>
              <div class="flex-none p-2">
                <p class="shadow p-5 bg-red-300 rounded-md" role="alert">
                  <%= Phoenix.Naming.humanize(msg) %>
                </p>
              </div>
            <% end %>

            <div class="flex">
              <%= live_file_input @uploads.image %>
              <input class="btn flex-col cursor-pointer" type="submit" value="Upload"></input>
            </div>
          </div>

          <%= for entry <- @uploads.image.entries do %>
            <div class="col-span-6">
              <div class="flex-col">
                <%= live_img_preview entry, width: 50, height: 50 %>
              </div>
              <div class="flex-col">
                <progress max="100" value="<%= entry.progress %>"/>
              </div>
              <div class="flex-col">
                <div class="btn cursor-pointer inline"
                      phx-click="cancel-entry"
                      phx-value-ref="<%= entry.ref %>">
                  cancel
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </form>
      </div>
    """
  end

  def mount(_params, %{"item_uuid" => item_uuid} = _session, socket) do
    item = Cvs.get_section_item!(item_uuid)

    {:ok,
     socket
     |> assign(:item, item)
     |> assign(:uploaded_files, [])
     |> allow_upload(:image,
       accept: ~w(.png .jpg .jpeg),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  def handle_event("save", event, socket) do
    {:ok, item} =
      Cvs.update_section_item(
        socket.assigns.item,
        Map.take(event, ["date_from", "date_to", "title", "subtitle", "content", "footer"])
      )

    {:noreply, assign(socket, item: item, info: "Item saved")}
  end

  def handle_event("upload", _event, socket) do
    {:ok, item} =
      Cvs.update_section_item(
        socket.assigns.item,
        %{},
        &consume_image(socket, &1)
      )

    {:noreply, assign(socket, item: item, info: "Item saved")}
  end

  def handle_event("date-changed", %{"field" => field, "value" => value}, socket) do
    {:ok, item} =
      Cvs.update_section_item(
        socket.assigns.item,
        %{field => value}
      )

    {:noreply, assign(socket, item: item, info: "Item saved")}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("remove-image", _event, %{assigns: assigns} = socket) do
    {:ok, item} = Cvs.update_section_item(assigns.item, %{image: nil, image_type: nil})
    {:noreply, assign(socket, item: item, info: "Item saved")}
  end

  # sobelow_skip ["Traversal.FileModule"]
  def consume_image(socket, attrs) do
    [{binary_data, type}] =
      consume_uploaded_entries(socket, :image, fn meta, entry ->
        {File.read!(meta.path), entry.client_type}
      end)

    attrs
    |> Map.put(:image, binary_data)
    |> Map.put(:image_type, type)
  end
end
