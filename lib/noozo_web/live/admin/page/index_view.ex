defmodule NoozoWeb.Admin.Page.IndexView do
  @moduledoc """
  Admin pages index live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Core
  alias Noozo.Pagination

  alias NoozoWeb.Admin.Page.CreateView
  alias NoozoWeb.Admin.Page.EditView

  data loading, :boolean, default: true

  @impl true
  def render(assigns) do
    ~F"""
    {#if @loading}
      <div>Loading information...</div>
    {#else}
      <LivePatch to={Routes.live_path(@socket, CreateView)} class="btn">Create Page</LivePatch>

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
                      Slug
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {#for page <- @pages.entries}
                    <tr>
                      <td>
                        <LivePatch to={Routes.live_path(@socket, EditView, page.id)} class="btn">{page.title}</LivePatch>
                      </td>
                      <td>
                        {page.slug}
                      </td>
                    </tr>
                  {/for}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <Pagination source_assigns={assigns} entries={@pages} module={__MODULE__} />
    {/if}
    """
  end

  @impl true
  def handle_info({:load_pages, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       pages: Core.list_pages(params)
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    send(self(), {:load_pages, params})
    {:noreply, assign(socket, loading: true)}
  end
end
