defmodule NoozoWeb.Admin.Cvs.CreateView do
  @moduledoc """
  Admin CVs create live view
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Cvs
  alias NoozoWeb.Admin.Cvs.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    Creating cv...
    """
  end

  def mount(_params, session, socket) do
    {:ok, assign(socket, current_user: session["current_user"])}
  end

  def handle_params(_params, _uri, %{assigns: assigns} = socket) do
    {:ok, cv} = Cvs.create_cv(%{title: "Untitled CV", user_id: assigns.current_user.id})

    {:noreply,
     socket
     |> put_flash(:info, "CV created")
     |> redirect(to: Routes.live_path(socket, EditView, cv.uuid))}
  end
end
