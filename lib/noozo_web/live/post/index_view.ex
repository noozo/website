defmodule NoozoWeb.Post.IndexView do
  use NoozoWeb, :surface_view

  alias Noozo.Core

  alias NoozoWeb.Post.Components.Post

  import Noozo.Pagination

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      {#if @tag}
        <div class="md:text-2xl lg:text-2xl xl:text-4xl font-bold mb-6">
          Posts about {@tag.name}
        </div>
      {/if}

      <div class="flex flex-grow flex-col flex-nowrap gap-8 md:min-w-full">
        {#if Enum.any?(@posts.entries)}
          {#for post <- @posts.entries}
            <Post post={post} ga_id={@ga_id} />
          {/for}
        {#else}
          <p class="text-center">
            There is nothing here.
            Why don't you <a class="underline" href="/admin/posts">write something</a>?
          </p>
        {/if}
      </div>

      {live_paginate(assigns, @posts, __MODULE__, @socket)}
    </div>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       current_user: session["current_user"],
       ga_id: session["ga_id"],
       tag: nil,
       page_title: "Writings"
     )}
  end

  @impl true
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
