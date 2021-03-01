defmodule NoozoWeb.Admin.Accounts.IndexView do
  @moduledoc """
  User accounts index view
  """
  use Phoenix.LiveView

  import Noozo.Pagination

  alias Noozo.Accounts

  alias NoozoWeb.Admin.Accounts.{EditView, TwoFactorSetupView}
  alias NoozoWeb.Router.Helpers, as: Routes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, users: Accounts.list_users(params))}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="flex flex-col mt-6">
        <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
            <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
              <table>
                <thead>
                  <tr>
                    <th scope="col">Id</th>
                    <th scope="col">Email</th>
                    <th scope="col">Has 2FA?</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for user <- @users.entries do %>
                    <tr>
                      <td>
                        <%= live_patch user.id, to: Routes.live_path(@socket, EditView, user.id) %>
                      </td>
                      <td>
                        <%= live_patch user.email, to: Routes.live_path(@socket, EditView, user.id) %>
                      </td>
                      <td>
                        <%= user.has_2fa %>
                        <%= live_patch "Setup/View", to: Routes.live_path(@socket, TwoFactorSetupView, user.id) %>.
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <%= live_paginate(assigns, @users, __MODULE__, @socket) %>
    """
  end
end
