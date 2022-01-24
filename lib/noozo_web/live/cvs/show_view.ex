defmodule NoozoWeb.Cvs.ShowView do
  use NoozoWeb, :surface_view

  alias Noozo.Cvs

  alias NoozoWeb.Admin.Cvs.Children.PreviewView, as: Preview

  @impl true
  def render(assigns) do
    ~F"""
    {#if @cv}
      {live_render(@socket, Preview, id: :preview, session: %{"cv_uuid" => @cv.uuid})}
    {#else}
      <p class="text-center">The logged in user has no CVs</p>
    {/if}
    """
  end

  @impl true
  def handle_params(%{"user_id" => user_id} = _params, _uri, socket) do
    cv = Cvs.get_user_cv!(user_id)
    {:noreply, assign(socket, cv: cv, page_title: "Resume: #{cv.title}")}
  end
end
