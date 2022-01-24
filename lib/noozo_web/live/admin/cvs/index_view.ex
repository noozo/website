defmodule NoozoWeb.Admin.Cvs.IndexView do
  @moduledoc """
  Admin CVs index live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Cvs
  alias Noozo.Pagination
  alias NoozoWeb.Admin.Cvs.CreateView
  alias NoozoWeb.Admin.Cvs.EditView

  data loading, :boolean, default: true

  @impl true
  def render(assigns) do
    ~F"""
    {#if @loading}
      <div>Loading information...</div>
    {#else}
      <LivePatch to={Routes.live_path(@socket, CreateView)} class="btn">CreateCV</LivePatch>

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
                  {#for cv <- @cvs.entries}
                    <tr>
                      <td>
                        <LivePatch to={Routes.live_path(@socket, EditView, cv.uuid)} class="btn">{cv.title}</LivePatch>
                      </td>
                      <td>
                        {cv.user.email}
                      </td>
                    </tr>
                  {/for}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <Pagination source_assigns={assigns} entries={@cvs} module={__MODULE__} />
    {/if}
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
