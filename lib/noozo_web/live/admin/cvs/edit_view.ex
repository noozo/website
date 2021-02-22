defmodule NoozoWeb.Admin.Cvs.EditView do
  @moduledoc """
  Admin CVs edit live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Cvs

  alias NoozoWeb.Admin.Cvs.Children.HeaderItemsView, as: HeaderItems
  alias NoozoWeb.Admin.Cvs.Children.PreviewView, as: Preview
  alias NoozoWeb.Admin.Cvs.Children.SectionsView, as: Sections
  alias NoozoWeb.Admin.Cvs.IndexView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= live_patch "Back to list", to: Routes.live_path(@socket, IndexView), class: "btn" %>

    <div class="flex-none p-5">
      <%= unless is_nil(@info) do %>
        <div class="shadow p-5 bg-green-300 rounded-md" role="alert"><%= @info %></div>
      <% end %>
      <%= unless is_nil(@error) do %>
        <div class="shadow p-5 bg-red-300 rounded-md" role="alert"><%= @error %></div>
      <% end %>
    </div>

    <div class="mt-2 md:mt-0 md:col-span-2 grid grid-cols-2 gap-6 max-w-full">
      <div class="shadow sm:rounded-md sm:overflow-hidden">
        <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
          <form class="mb-6 mr-6" phx-change="save" phx-debounce="500">
            <div class="grid grid-cols-6 gap-6">
              <div class="col-span-6">
                <label for="title">
                  Belongs to <%= @cv.user.email %>
                </label>
              </div>

              <div class="col-span-6 sm:col-span-3">
                <label for="title">
                  Title
                </label>
                <div class="mt-1">
                  <input type='text' name='title' value='<%= @cv.title %>' phx-debounce="500" />
                </div>
              </div>

              <div class="col-span-6 sm:col-span-3">
                <label for="title">
                  Subtitle
                </label>
                <div class="mt-1">
                  <input type='text' name='subtitle' value='<%= @cv.subtitle %>' phx-debounce="500" />
                </div>
              </div>

              <div class="col-span-6">
                <label for="abstract">Abstract</label>
                <textarea ype='text' name='abstract' phx-debounce="500" rows="10"><%= @cv.abstract %></textarea>
              </div>
            </div>
          </form>

          <form phx-submit="upload" phx-change="validate"
                class="col-span-6 sm:col-span-3"
                :class="{'hidden': collapsed, 'visible': !collapsed}">
            <div class="grid grid-cols-6 gap-4 mt-4">
              <label for="image">Image</label>

              <%= if @cv.image do %>
                <div class="block mr-6" phx-click="remove-image" data-confirm="Remove image?">
                  <%=
                    data = Base.encode64(@cv.image)
                    Phoenix.HTML.raw(
                      "<img src=\"data:"<>@cv.image_type<>";base64,"<>data<>"\" width=\"50px\">"
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

          <%= live_render @socket, HeaderItems, id: :cv_header_items, session: %{"cv_uuid" => @cv.uuid} %>
          <%= live_render @socket, Sections, id: :sections_view, session: %{"cv_uuid" => @cv.uuid} %>
        </div>
      </div>

      <div class="shadow sm:rounded-md sm:overflow-hidden">
        <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
          <%= live_render @socket, Preview, id: :preview, session: %{"cv_uuid" => @cv.uuid} %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:info, nil)
     |> assign(:error, nil)
     |> assign(:uploaded_files, [])
     |> allow_upload(:image,
       accept: ~w(.png .jpg .jpeg),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  def handle_params(params, _uri, socket) do
    cv = Cvs.get_cv!(params["uuid"])
    {:noreply, assign(socket, cv: cv)}
  end

  def handle_event(
        "save",
        %{"title" => title, "subtitle" => subtitle, "abstract" => abstract} = _event,
        socket
      ) do
    {:ok, cv} =
      Cvs.update_cv(socket.assigns.cv, %{
        title: String.trim(title),
        subtitle: String.trim(subtitle),
        abstract: String.trim(abstract)
      })

    {:noreply, assign(socket, cv: cv)}
  end

  def handle_event("upload", _event, socket) do
    {:ok, cv} =
      Cvs.update_cv(
        socket.assigns.cv,
        %{},
        &consume_image(socket, &1)
      )

    {:noreply, assign(socket, cv: cv)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("remove-image", _event, %{assigns: assigns} = socket) do
    {:ok, cv} = Cvs.update_cv(assigns.cv, %{image: nil, image_type: nil})
    {:noreply, assign(socket, cv: cv)}
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
