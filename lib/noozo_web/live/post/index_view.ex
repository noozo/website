defmodule NoozoWeb.Post.IndexView do
  use Phoenix.LiveView

  alias Noozo.Core

  import Noozo.Pagination

  def render(assigns) do
    ~L"""
    <div>
      <%= if @tag do %>
        <div class="md:text-2xl lg:text-2xl xl:text-4xl font-bold mb-6">Posts about <%= @tag.name %></div>
      <% end %>

      <div class="flex flex-grow flex-col flex-nowrap gap-8 md:min-w-full">
        <%= for post <- @posts.entries do %>
          <%= live_component(@socket, NoozoWeb.Post.Components.Post, post: post, ga_id: @ga_id) %>
        <% end %>
      </div>

      <%= live_paginate(assigns, @posts, __MODULE__, @socket) %>
    </div>
    """
  end

  def mount(_params, session, socket) do
    {:ok,
     assign(socket, current_user: session["current_user"], ga_id: session["ga_id"], tag: nil)}
  end

  def handle_params(params, _uri, socket) do
    params = Map.put(params, :page_size, 4)

    assigns =
      case get_tag(params) do
        {:ok, tag} ->
          tag_id = if tag, do: tag.id, else: nil
          %{posts: Core.list_posts(Map.put(params, :tag_id, tag_id)), tag: tag}

        _ ->
          %{posts: Core.list_posts(params)}
      end

    {:noreply, assign(socket, assigns)}
  end

  defp get_tag(params) do
    case params["tag"] do
      nil ->
        nil

      slug ->
        tag = slug |> URI.decode() |> Core.get_tag!()

        case tag do
          nil -> nil
          tag -> {:ok, tag}
        end
    end
  end
end
