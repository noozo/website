defmodule NoozoWeb.Post.Components.Likes do
  @moduledoc """
  Likes component
  """
  use NoozoWeb, :surface_component

  alias Noozo.Core

  prop ga_id, :string, required: true
  prop post, :struct, required: true
  prop icon_class, :string
  prop user_liked, :boolean
  prop tooltip, :string
  prop like_text, :string

  @impl true
  def update(assigns, socket) do
    data =
      assigns
      |> setup_like(assigns.post)
      |> Map.put(:id, assigns.id)
      |> Map.put(:ga_id, assigns.ga_id)
      |> Map.put(:post, assigns.post)

    {:ok, assign(socket, data)}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="likes">
      <span
        id={"likes_#{@post.id}"}
        class={"icon #{@icon_class} has-tooltip-arrow"}
        phx-hook="TooltipInit"
        phx-click="toggle_like"
        phx-value-user_liked={@user_liked}
        data-tooltip={@tooltip}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          class="w-4 cursor-pointer inline"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
          />
        </svg>
        {@like_text}
      </span>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_like", %{"user_liked" => "false"} = _event, socket) do
    # Wants to like
    {:ok, post} = Core.like_post(socket.assigns.ga_id, socket.assigns.post.id)
    {:noreply, assign(socket, setup_like(socket.assigns, post))}
  end

  @impl true
  def handle_event("toggle_like", %{"user_liked" => "true"} = _event, socket) do
    # Wants to dislike
    {:ok, post} = Core.dislike_post(socket.assigns.ga_id, socket.assigns.post.id)
    {:noreply, assign(socket, setup_like(socket.assigns, post))}
  end

  defp setup_like(assigns, post) do
    user_liked = post.post_likes |> Enum.map(&(&1.ga_id == assigns.ga_id)) |> length() > 0

    [icon_class, tooltip, like_text] =
      if user_liked do
        ["liked", "Click to dislike", "You and #{post.like_count - 1} other people like this"]
      else
        ["", "Click to like", "#{post.like_count} people like this"]
      end

    %{}
    |> Map.put(:user_liked, user_liked)
    |> Map.put(:icon_class, icon_class)
    |> Map.put(:like_text, like_text)
    |> Map.put(:tooltip, tooltip)
    |> Map.put(:post, post)
  end
end
