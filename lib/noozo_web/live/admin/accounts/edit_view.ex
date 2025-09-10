defmodule NoozoWeb.Admin.Accounts.EditView do
  @moduledoc """
  Admin accounts edit live view
  """
  use NoozoWeb, :live_view

  alias Noozo.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Edit User</h1>
    <p>User ID: {@user.id}</p>
    <p>Email: {@user.email}</p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => user_id}, _uri, socket) do
    user = Accounts.get_user!(user_id)
    {:noreply, assign(socket, user: user)}
  end
end
