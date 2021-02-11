defmodule NoozoWeb.ErrorController do
  use NoozoWeb, :controller

  def not_found(conn, _params) do
    render(conn, "404.html")
  end
end
