defmodule NoozoWeb.Admin.Page.EditView do
  @moduledoc """
  Admin pages edit live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Core
  alias NoozoWeb.Admin.Page.IndexView
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

    <div class="mt-2 md:mt-0 md:col-span-2">
      <form class="mb-6" phx-change="save" phx-debounce="500">
        <div class="shadow sm:rounded-md sm:overflow-hidden">
          <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
            <div class="grid grid-cols-6 gap-6">
              <div class="col-span-6 sm:col-span-3">
                <label for="title" class="block text-sm font-medium text-gray-700">
                  Title
                </label>
                <div class="mt-1">
                  <input class='shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md'
                         type='text' name='title' value='<%= @page.title %>' phx-debounce="5000" />
                </div>
              </div>
            </div>

          <div>
            <label for="content" class="block text-sm font-medium text-gray-700">
              Content
            </label>
            <div class="mt-1">
              <textarea class='shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md'
                        type='text' name='content' rows="20" phx-debounce="5000"><%= @page.content %></textarea>
            </div>
          </div>
        </div>
      </form>
    </div>

    <div class="max-w-full border-2 border-dashed border-gray-200 p-4 prose lg:prose-xl">
      <h2 class="title"><%= @page.title %></h2>
      <div class="block">
        <%= @page.content |> Phoenix.HTML.raw() %>
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
    {:noreply, assign(socket, page: Core.get_page!(params["id"]))}
  end

  def handle_event(
        "save",
        %{"_target" => _target, "title" => title, "content" => content} = _event,
        socket
      ) do
    {:ok, page} =
      Core.update_page(socket.assigns.page, %{
        title: String.trim(title),
        content: String.trim(content)
      })

    {:noreply,
     assign(socket,
       page: page,
       info: "Page saved"
     )}
  end
end
