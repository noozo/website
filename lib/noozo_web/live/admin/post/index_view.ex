defmodule NoozoWeb.Admin.Post.IndexView do
  @moduledoc """
  Admin posts index live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Core
  alias Noozo.Pagination

  alias NoozoWeb.Admin.Post.CreateView
  alias NoozoWeb.Admin.Post.EditView
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  @doc "Wether the data is loading or not"
  data loading, :boolean, default: true

  @impl true
  def handle_info({:load_posts, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       posts: Core.list_posts(params, false)
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    send(self(), {:load_posts, params})
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~F"""
    {#if @loading}
      <div>Loading information...</div>
    {#else}
      <LivePatch to={Routes.live_path(@socket, CreateView)} class="btn">Create Post</LivePatch>

      <!-- This example requires Tailwind CSS v2.0+ -->
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
                    <th scope="col">
                      Status
                    </th>
                    <th scope="col">
                      Published at
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {#for post <- @posts.entries}
                    <tr>
                      <td>
                        <LivePatch to={Routes.live_path(@socket, EditView, post.id)} class="btn">{post.title}</LivePatch>
                      </td>
                      <td>
                        {post.slug}
                      </td>
                      <td>
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                          {post.status}
                        </span>
                      </td>
                      <td class="text-sm text-gray-500">
                        {TemplateUtils.format_date(post.published_at)}
                      </td>
                    </tr>
                  {/for}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <Pagination source_assigns={assigns} entries={@posts} module={__MODULE__} />
    {/if}
    """
  end
end
