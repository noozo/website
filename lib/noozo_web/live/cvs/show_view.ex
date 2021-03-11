defmodule NoozoWeb.Cvs.ShowView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Cvs

  alias NoozoWeb.Admin.Cvs.Children.PreviewView, as: Preview

  def render(assigns) do
    ~L"""
      <%= if @cv do %>
        <%= live_render @socket, Preview, id: :preview, session: %{"cv_uuid" => @cv.uuid} %>
      <% else %>
        <p class="text-center">The logged in user has no CVs</p>
      <% end %>
    """
  end

  def handle_params(%{"user_id" => user_id} = _params, _uri, socket) do
    cv = Cvs.get_user_cv!(user_id)
    {:noreply, assign(socket, cv: cv, page_title: "Resume: #{cv.title}")}
  end
end
