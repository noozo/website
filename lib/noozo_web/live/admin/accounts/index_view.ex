defmodule NoozoWeb.Admin.Accounts.IndexView do
  @moduledoc """
  User accounts index view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Accounts
  alias Noozo.Pagination

  alias NoozoWeb.Admin.Accounts.{EditView, TwoFactorSetupView}

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, users: Accounts.list_users(params))}
  end

  @impl true
  def render(assigns) do
    ~F"""
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
                {#for user <- @users.entries}
                  <tr>
                    <td>
                      <LivePatch to={Routes.live_path(@socket, EditView, user.id)}>{user.id}</LivePatch>
                    </td>
                    <td>
                      <LivePatch to={Routes.live_path(@socket, EditView, user.id)}>{user.email}</LivePatch>
                    </td>
                    <td>
                      {user.has_2fa}
                      <LivePatch to={Routes.live_path(@socket, TwoFactorSetupView, user.id)}>Setup/View</LivePatch>
                    </td>
                  </tr>
                {/for}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <Pagination source_assigns={assigns} entries={@users} module={__MODULE__} />
    """
  end
end
