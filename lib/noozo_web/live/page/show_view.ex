defmodule NoozoWeb.Page.ShowView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Core
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @page do  %>
      <div id={@page.id}>
        <%= if @current_user do %>
          <div class="mt-5 flex lg:mt-0 lg:ml-4 float-right">
            <span class="hidden sm:block">
              <%= live_patch to: Routes.live_path(@socket, NoozoWeb.Admin.Page.EditView, @page.id), class: "inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-black bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" do %>
                <!-- Heroicon name: pencil -->
                <svg class="-ml-1 mr-2 h-5 w-5 text-black" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                </svg>
                Edit
              <% end %>
            </span>
          </div>
        <% end %>

        <div class="max-w-full prose lg:prose-lg">
          <%= TemplateUtils.post_content(@page) %>
        </div>
      </div>
    <% else %>
      <p class="text-center">That page doesn't seem to exist. Maybe you want to <a class="underline" href="/admin/pages">create it</a>?</p>
    <% end %>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, :current_user, session["current_user"])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = Core.get_page_by_slug(params["slug"])
    {:noreply, assign(socket, page: page, page_title: page.title)}
  end
end
