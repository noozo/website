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

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <%= live_patch("Create CV", to: Routes.live_path(@socket, CreateView), class: "btn") %>

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
                        <%= live_patch(cv.title, to: Routes.live_path(@socket, EditView, cv.uuid)) %>
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

      <%= live_paginate(assigns, @cvs, __MODULE__, @socket) %>
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: true)}
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
