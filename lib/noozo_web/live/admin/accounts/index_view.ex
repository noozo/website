defmodule NoozoWeb.Admin.Accounts.IndexView do
  @moduledoc """
  User accounts index view
  """
  use NoozoWeb, :live_view

  alias Noozo.Accounts

  alias NoozoWeb.Admin.Accounts.{EditView, TwoFactorSetupView}

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, users: Accounts.list_users(params))}
  end

  @impl true
  def render(assigns) do
    ~H"""
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
                      <.link navigate={~p"/admin/users/#{user.id}/edit"}><%= user.id %></.link>
                    </td>
                    <td>
                      <.link navigate={~p"/admin/users/#{user.id}/edit"}><%= user.email %></.link>
                    </td>
                    <td>
                      <%= user.has_2fa %>
                      <.link navigate={~p"/admin/users/#{user.id}/setup_2fa"}>Setup/View</.link>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <%= Noozo.Pagination.render(%{source_assigns: assigns, entries: @users, module: __MODULE__ }) %>
    """
  end
end
