defmodule NoozoWeb.Admin.Page.IndexView do
  @moduledoc """
  Admin pages index live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Core
  alias NoozoWeb.Admin.Page.CreateView
  alias NoozoWeb.Admin.Page.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <%= live_patch("Create Page", to: Routes.live_path(@socket, CreateView), class: "btn") %>

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
                  <%= for page <- @pages.entries do %>
                    <tr>
                      <td>
                        <%= live_patch(page.title, to: Routes.live_path(@socket, EditView, page.id)) %>
                      </td>
                      <td>
                        <%= page.slug %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <%= live_paginate(assigns, @pages, __MODULE__, @socket) %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: true)}
  end

  def handle_info({:load_pages, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       pages: Core.list_pages(params)
     )}
  end

  def handle_params(params, _uri, socket) do
    send(self(), {:load_pages, params})
    {:noreply, assign(socket, loading: true)}
  end
end
