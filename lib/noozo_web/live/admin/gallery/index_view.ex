defmodule NoozoWeb.Admin.Gallery.IndexView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Gallery

  alias NoozoWeb.Admin.Gallery.CreateView
  alias NoozoWeb.Admin.Gallery.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _session, socket) do
    images = Gallery.list(params)
    {:noreply, assign(socket, :images, images)}
  end

  def render(assigns) do
    ~L"""
    <%= live_patch("Upload Image", to: Routes.live_path(@socket, CreateView), class: "btn") %>

    <div class="flex flex-col mt-6">
      <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
          <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
            <table>
              <thead>
                <tr>
                  <th scope="col">
                    Title
                  </th>
                  <th scope="col">
                    Preview
                  </th>
                  <th scope="col">
                    Order
                  </th>
                </tr>
              </thead>
              <tbody>
                <%= for image <- @images.entries do %>
                  <tr>
                    <td>
                      <%= live_patch(image.title, to: Routes.live_path(@socket, EditView, image.uuid)) %>
                    </td>
                    <td>
                      <%=
                        data = Base.encode64(image.image)
                        Phoenix.HTML.raw(
                          "<img class=\"h-20\" src=\"data:"<>image.image_type<>";base64,"<>data<>"\">"
                        )
                      %>
                    </td>
                    <td>
                      <%= image.order %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <%= live_paginate(assigns, @images, __MODULE__, @socket) %>
    """
  end
end
