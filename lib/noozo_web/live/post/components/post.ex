defmodule NoozoWeb.Post.Components.Post do
  @moduledoc """
  A post
  """
  use Phoenix.LiveComponent

  alias Noozo.Core.Post

  alias NoozoWeb.Post.ShowView
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  def update(assigns, socket) do
    data =
      assigns
      |> Map.put(:post, assigns.post)
      |> Map.put(:ga_id, assigns.ga_id)

    {:ok, assign(socket, data)}
  end

  def render(assigns) do
    ~L"""
    <div class="px-6 py-6 bg-white rounded-lg shadow-md border">
      <div class="flex flex-row flex-grow gap-6">
        <div>
          <%= if @post.image do %>
            <%= live_patch to: Routes.live_path(@socket, ShowView, @post.slug) do %>
              <img alt="<%= @post.title %>" class="w-24 h-auto md:w-32 md:rounded-none rounded-full"
                   src="<%= Post.image_url(@post) %>" />
            <% end %>
          <% end %>
        </div>

        <div>
          <div class="flex justify-between items-center">
            <span class="font-light text-black">
              <%= TemplateUtils.format_date(@post.published_at) %>
            </span>
            <div class="hidden md:inline">
              <%= for tag <- assigns.post.tags do %>
                <div class="tag-xs text-xs inline">
                  <a href="<%= Routes.live_path(@socket, NoozoWeb.Post.IndexView, tag.name) %>">
                    <%= tag.name %>
                  </a>
                </div>
              <% end %>
            </div>
          </div>

          <div class="mt-2">
            <%= live_patch @post.title, to: Routes.live_path(@socket, ShowView, @post.slug), class: "text-2xl text-black font-bold hover:underline" %>
            <p class="mt-2 text-black">
              <%= TemplateUtils.abstract(@post.content) %>
            </p>
          </div>

          <div class="flex justify-between items-center mt-4">
            <%= live_patch "Read more", to: Routes.live_path(@socket, ShowView, @post.slug), class: "hover:underline" %>
            <div>
              <a href="/resume/1" class="flex items-center"><img
                  src="https://avatars.githubusercontent.com/u/3353?s=48&u=07467282a87d8ad4d4f07ae54266cd85a3cc2cbb&v=4"
                  alt="avatar" class="mx-4 w-10 h-10 object-cover rounded-full hidden sm:block">
                <h1 class="text-black font-bold hover:underline">Pedro A.</h1>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
