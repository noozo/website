defmodule NoozoWeb.Post.ShowView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias Noozo.Core
  alias NoozoWeb.Post.IndexView
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  def render(assigns) do
    ~L"""
    <div class="lg:flex lg:items-center lg:justify-between mb-8" id="<%= @post.id %>">
      <div class="flex-1 min-w-0">
        <%= render_tags(assigns) %>

        <h2 class="text-2xl font-bold leading-7 text-black sm:text-3xl sm:truncate mt-4">
          <%= if @post.status == "published", do: "", else: "[DRAFT] " %><%= @post.title %>
        </h2>

        <div class="mt-1 flex flex-col sm:flex-row sm:flex-wrap sm:mt-0 sm:space-x-6">
          <div class="mt-2 flex items-center text-sm text-black">
            <!-- Heroicon name: calendar -->
            <svg class="flex-shrink-0 mr-1.5 h-5 w-5 text-black" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
            </svg>
            <%= TemplateUtils.format_date(@post.published_at) %>
          </div>

          <div class="mt-2 flex items-center text-sm text-black">
            <%= live_component(@socket, NoozoWeb.Post.Components.Likes, id: @post.id, post: @post, ga_id: @ga_id) %>
          </div>
        </div>
      </div>

      <%= if @current_user do %>
        <div class="mt-5 flex lg:mt-0 lg:ml-4">
          <span class="hidden sm:block">
            <%= live_patch to: Routes.live_path(@socket, NoozoWeb.Admin.Post.EditView, @post.id), class: "inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-black bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" do %>
              <!-- Heroicon name: pencil -->
              <svg class="-ml-1 mr-2 h-5 w-5 text-black" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
              </svg>
              Edit
            <% end %>
          </span>
        </div>
      <% end %>
    </div>

    <%= if @post.image do %>
      <div class="block mr-6 mb-6 float-left">
        <%=
          data = Base.encode64(@post.image)
          Phoenix.HTML.raw(
            "<img src=\"data:"<>@post.image_type<>";base64,"<>data<>"\" width=\"200px\">"
          )
        %>
      </div>
    <% end %>

    <div class="max-w-full prose lg:prose-lg">
      <%= TemplateUtils.post_content(@post) %>
    </div>

    <div class="block is-pulled-right">
      <!-- Facebook -->
      <a target="_blank" href="https://www.facebook.com/sharer/sharer.php?u=<%= URI.encode_www_form(@url) %>&amp;src=sdkpreparse" class="fb-xfbml-parse-ignore">
        <img class="inline" src="/images/bw/facebook_20x20.png"  width="20px" height="20px" />
      </a>

      <!-- Twitter -->
      <a target="_blank" class="twitter-share-button" href="https://twitter.com/intent/tweet?text=I%20wrote%20a%20new%20article%20<%= URI.encode_www_form(@url) %>">
        <img class="inline" src="/images/bw/twitter_20x20.png"  width="20px" height="20px" />
      </a>

      <!-- LinkedIn -->
      <a target="_blank" class="twitter-share-button" href="https://www.linkedin.com/shareArticle?mini=true&url=<%= URI.encode_www_form(@url) %>&title=<%= @post.title %>">
        <img class="inline" src="/images/bw/linkedin_20x20.png"  width="20px" height="20px" />
      </a>
    </div>

    <div class="block mt-6">
      <%= live_patch "&lt;&lt; back to posts" |> Phoenix.HTML.raw(), to: Routes.live_path(@socket, IndexView), class: "btn" %>
    </div>
    """
  end

  defp render_tags(assigns) do
    ~L"""
    <%= if length(assigns.post.tags) > 0 do %>
      <%= for tag <- assigns.post.tags do %>
        <div class="tag">
          <a href="<%= Routes.live_path(@socket, NoozoWeb.Post.IndexView, tag.name) %>">
            <%= tag.name %>
          </a>
        </div>
      <% end %>
    <% end %>
    """
  end

  def mount(_params, session, socket) do
    {:ok, assign(socket, current_user: session["current_user"], ga_id: session["ga_id"])}
  end

  def handle_params(params, uri, socket) do
    {:noreply, assign(socket, post: fetch_post(params["slug"]), url: uri)}
  end

  # By id or slug
  defp fetch_post(slug_or_id) do
    case Integer.parse(slug_or_id) do
      {_, ""} -> Core.get_post!(slug_or_id)
      _ -> Core.get_post_by_slug!(slug_or_id)
    end
  end
end
