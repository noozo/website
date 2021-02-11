defmodule NoozoWeb.ResumeRedirectController do
  @moduledoc """
  Catch all controller
  """
  use NoozoWeb, :controller

  def redirect(conn, _params) do
    base_url = Application.fetch_env!(:noozo, :https_redirect_url)
    Phoenix.Controller.redirect(conn, external: "https://#{base_url}/resume/1")
  end
end
