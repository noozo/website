defmodule NoozoWeb.CurrentUserPlug do
  @moduledoc """
  Assigns the current user into the connection based on the session
  """
  import Plug.Conn
  use NoozoWeb, :controller

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    assign(conn, :current_user, get_session(conn, "current_user"))
  end
end
