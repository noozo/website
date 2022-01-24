defmodule NoozoWeb.Admin.Gallery.IndexView do
  use NoozoWeb, :surface_view

  alias Noozo.Gallery
  alias Noozo.Pagination

  alias NoozoWeb.Admin.Gallery.CreateView
  alias NoozoWeb.Admin.Gallery.EditView

  @impl true
  def handle_params(params, _session, socket) do
    images = Gallery.list(params)
    {:noreply, assign(socket, :images, images)}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <LivePatch to={Routes.live_path(@socket, CreateView)} class="btn">Upload Image</LivePatch>

    <div class="flex flex-col mt-6">
      <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
          <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
            <table>
              <thead>
                <tr>
                  <th scope="col">Title</th>
                  <th scope="col">Preview</th>
                  <th scope="col">Order</th>
                </tr>
              </thead>
              <tbody>
                {#for image <- @images.entries}
                  <tr>
                    <td>
                      <LivePatch to={Routes.live_path(@socket, EditView, image.uuid)}>{image.title}</LivePatch>
                    </td>
                    <td>
                      {data = Base.encode64(image.image)

                      Phoenix.HTML.raw(
                        "<img class=\"h-20\" src=\"data:" <> image.image_type <> ";base64," <> data <> "\">"
                      )}
                    </td>
                    <td>
                      {image.order}
                    </td>
                  </tr>
                {/for}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <Pagination source_assigns={assigns} entries={@images} module={__MODULE__} />
    """
  end
end
