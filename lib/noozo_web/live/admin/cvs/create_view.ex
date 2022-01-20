defmodule NoozoWeb.Admin.Cvs.CreateView do
  @moduledoc """
  Admin CVs create live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Cvs
  alias NoozoWeb.Admin.Cvs.EditView

  @impl true
  def render(assigns) do
    ~F"""
    Creating cv...
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, current_user: session["current_user"])}
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: assigns} = socket) do
    {:ok, cv} = Cvs.create_cv(%{title: "Untitled CV", user_id: assigns.current_user.id})

    {:noreply,
     socket
     |> put_flash(:info, "CV created")
     |> redirect(to: Routes.live_path(socket, EditView, cv.uuid))}
  end
end
