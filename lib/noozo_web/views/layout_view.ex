defmodule NoozoWeb.LayoutView do
  use NoozoWeb, :view

  # sobelow_skip ["XSS.Raw"]
  def controller_css(conn) do
    file =
      conn.private.phoenix_controller
      |> Atom.to_string()
      |> String.split(".")
      |> List.last()
      |> String.replace("Controller", "")
      |> String.downcase()

    href = Routes.static_path(conn, "/css/#{file}.css")

    Phoenix.HTML.raw(~s(<link rel="stylesheet" href="#{href}" />))
  end
end
