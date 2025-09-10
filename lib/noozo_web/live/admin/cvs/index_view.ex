defmodule NoozoWeb.Admin.Cvs.IndexView do
  @moduledoc """
  Admin CVs index live view
  """
  use NoozoWeb, :live_view

  alias Noozo.Cvs
  alias Noozo.Pagination
  alias NoozoWeb.Admin.Cvs.CreateView
  alias NoozoWeb.Admin.Cvs.EditView
  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <.link to={Routes.live_path(@socket, CreateView)} class="btn">CreateCV</.link>

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
                      Belongs to
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <%= for cv <- @cvs.entries do %>
                    <tr>
                      <td>
                        <.link to={Routes.live_path(@socket, EditView, cv.uuid)} class="btn"><%= cv.title %></.link>
                      </td>
                      <td>
                        <%= cv.user.email %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <%= Noozo.Pagination.render(%{source_assigns: assigns, entries: @cvs, module: __MODULE__}) %>
    <% end %>
    """
  end

  @impl true
  def handle_info({:load_cvs, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       cvs: Cvs.list_cvs(params)
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    send(self(), {:load_cvs, params})
    {:noreply, assign(socket, loading: true)}
  end
end
