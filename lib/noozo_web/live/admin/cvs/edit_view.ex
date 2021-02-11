defmodule NoozoWeb.Admin.Cvs.EditView do
  @moduledoc """
  Admin CVs edit live view
  """
  use Phoenix.LiveView

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
              <div class="col-span-6 sm:col-span-3">
                <label for="title" class="block text-sm font-medium text-gray-700">
                  Title
                </label>
                <div class="mt-1">
                  <input class='shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md'
                        type='text' name='title' value='<%= @cv.title %>' phx-debounce="500" />
                </div>
              </div>

              <div class="col-span-6 sm:col-span-3">
                <label for="title" class="block text-sm font-medium text-gray-700">
                  Belongs to <%= @cv.user.email %>
                </label>
              </div>
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
     |> assign(:error, nil)}
  end

  def handle_params(params, _uri, socket) do
    cv = Cvs.get_cv!(params["uuid"])
    {:noreply, assign(socket, cv: cv)}
  end

  def handle_event("save", %{"title" => title} = _event, socket) do
    {:ok, cv} =
      Cvs.update_cv(socket.assigns.cv, %{
        title: String.trim(title)
      })

    {:noreply, assign(socket, cv: cv)}
  end
end
