defmodule NoozoWeb.RedirectController do
  @moduledoc """
  Catch all controller
  """
  use NoozoWeb, :controller
  alias Noozo.Core

  def redirect(conn, params) do
    # Let's try to find a post with that path a slug
    [slug | _rest] = params["path"]
    post = Core.get_post_by_slug(slug)

    case post do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(NoozoWeb.ErrorView)
        |> render("404.html")

      p ->
        Phoenix.Controller.redirect(conn, to: "/posts/#{p.id}")
    end
  end
end
