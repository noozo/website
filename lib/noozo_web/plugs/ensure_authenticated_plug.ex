defmodule NoozoWeb.EnsureAuthenticatedPlug do
  @moduledoc """
  Ensures user is authenticated or redirects to login
  """
  import Plug.Conn
  use NoozoWeb, :controller

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    if get_session(conn, "current_user") do
      conn
    else
      conn
      |> put_flash(:error, "Restricted area. Please login.")
      |> redirect(
        to: Routes.auth_path(conn, :request, :identity, redirect_url: conn.request_path)
      )
      |> halt
    end
  end
end
