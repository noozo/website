defmodule NoozoWeb.Post.Components.Post do
  @moduledoc """
  A post
  """
  use NoozoWeb, :surface_component

  alias Noozo.Core.Post
  alias NoozoWeb.Endpoint
  alias NoozoWeb.Post.ShowView

  alias Surface.Components.LivePatch

  prop post, :struct, required: true
  prop ga_id, :string, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div class="px-6 py-6 bg-white rounded-lg shadow-md border">
      <div class="flex flex-row flex-grow gap-6">
        <div>
          {#if @post.image}
            <LivePatch to={Routes.live_path(Endpoint, ShowView, @post.slug)}>
              <img alt={@post.title} class="w-24 h-auto md:w-32 md:rounded-none rounded-full"
                   src={Post.image_url(@post)} />
            </LivePatch>
          {/if}
        </div>

        <div>
          <div class="flex justify-between items-center">
            <span class="font-light text-black">
              {TemplateUtils.format_date(@post.published_at)}
            </span>
            <div class="hidden md:inline">
              {#for tag <- assigns.post.tags}
                <div class="tag-xs text-xs inline">
                  <a href={Routes.live_path(Endpoint, NoozoWeb.Post.IndexView, tag.name)}>
                    {tag.name}
                  </a>
                </div>
              {/for}
            </div>
          </div>

          <div class="mt-2">
            <LivePatch to={Routes.live_path(Endpoint, ShowView, @post.slug)} class="text-2xl text-black font-bold hover:underline">
              {@post.title}
            </LivePatch>
            <p class="mt-2 text-black">
              {TemplateUtils.abstract(@post.content)}
            </p>
          </div>

          <div class="flex justify-between items-center mt-4">
            <LivePatch to={Routes.live_path(Endpoint, ShowView, @post.slug)} class="hover:underline">
              Read more
            </LivePatch>
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
