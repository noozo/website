defmodule NoozoWeb.Admin.Cvs.IndexView do
  @moduledoc """
  Admin CVs index live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Cvs
  alias NoozoWeb.Admin.Cvs.CreateView
  alias NoozoWeb.Admin.Cvs.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <%= live_patch("Create CV", to: Routes.live_path(@socket, CreateView), class: "btn") %>

      <div class="flex flex-col mt-6">
        <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
            <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Title
                    </th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Belongs to
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for cv <- @cvs.entries do %>
                    <tr>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <%= live_patch(cv.title, to: Routes.live_path(@socket, EditView, cv.uuid)) %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
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

      <%= live_paginate(assigns, @cvs, __MODULE__, @socket) %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: true)}
  end

  def handle_info({:load_cvs, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       cvs: Cvs.list_cvs(params)
     )}
  end

  def handle_params(params, _uri, socket) do
    send(self(), {:load_cvs, params})
    {:noreply, assign(socket, loading: true)}
  end
end
