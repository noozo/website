defmodule NoozoWeb.Admin.Post.EditView do
  @moduledoc """
  Admin posts edit live view
  """
  use Phoenix.HTML
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Core
  alias NoozoWeb.Admin.Post.IndexView
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:info, nil)
     |> assign(:error, nil)
     |> allow_upload(:cover_photo,
       accept: ~w(.png .jpg .jpeg),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= live_patch "Back to list", to: Routes.live_path(@socket, IndexView), class: "btn" %>

    <div class="flex-none p-5">
      <%= unless is_nil(@info) do %>
        <div class="shadow p-5 bg-green-300 rounded-md" role="alert"><%= @info %></div>
      <% end %>
      <%= unless is_nil(@error) do %>
        <div class="shadow p-5 bg-red-300 rounded-md" role="alert"><%= @error %></div>
      <% end %>
    </div>

    <div class="mt-5 md:mt-0 flex flex-row gap-6">
      <div class="mt-5 md:mt-0 flex flex-col">
        <form class="mb-4" phx-submit="save" phx-change="update-title-and-content">
          <div class="shadow sm:rounded-md sm:overflow-hidden">
            <div class="px-4 py-5 bg-white space-y-6 sm:p-6 flex flex-col gap-6">
              <div>
                <label for="title">
                  Title
                </label>
                <div class="mt-1">
                  <input type='text' name='title' value={@post.title} phx-debounce="500" />
                </div>
              </div>

              <div>
                <label for="content">
                  Content
                </label>
                <div class="mt-1">
                  <textarea class="w-full" type='text' name='content' rows="15" phx-debounce="500">
                    <%= @post.content %>
                  </textarea>
                </div>
              </div>

              <div>
                <label for="status">
                  Status
                </label>
                <div class="mt-1">
                  <select class="focus:ring-indigo-500 focus:border-indigo-500 h-full py-0 pl-2 pr-7 text-gray-500 sm:text-sm rounded-md"
                          name="status" phx-blur="update-status">
                    <%= TemplateUtils.status_item("draft", "Draft", @post) %>
                    <%= TemplateUtils.status_item("published", "Published", @post) %>
                  </select>
                </div>
              </div>

              <div>
                <%= for {_ref, msg} <- @uploads.cover_photo.errors do %>
                  <p class="alert alert-danger" role="alert">
                    <%= Phoenix.Naming.humanize(msg) %>
                  </p>
                <% end %>

                <%= live_file_input @uploads.cover_photo %>

                <%= for entry <- @uploads.cover_photo.entries do %>
                  <div class="columns">
                    <div class="column img-preview">
                      <%= live_img_preview entry, height: 80 %>
                    </div>
                    <div class="column">
                      <progress max="100" value={entry.progress} />
                    </div>
                    <div class="column">
                      <a href="#" phx-click="cancel-entry" phx-value-ref={entry.ref}>
                        cancel
                      </a>
                    </div>
                  </div>
                <% end %>

                <input class="btn" type="submit" value="Upload"/>
              </div>
            </div>
          </div>
        </form>
        <%= live_component Admin.Components.TitleSuggester, id: :title_suggester, post: @post %>
        <%= live_component Admin.Components.TagEditor, id: :tag_editor, post: @post %>
      </div>

      <div class="max-w-full border-2 border-dashed border-gray-200 p-4 prose lg:prose-xl">
        <h2><%= @post.title %></h2>
        <div class="date">
          <%= TemplateUtils.format_date(@post.published_at) %>
        </div>
        <%= if @post.image do %>
          <div class="block is-pulled-left mr-6" phx-click="remove-cover-photo" data-confirm="Remove image?">
            <%=
              data = Base.encode64(@post.image)
              Phoenix.HTML.raw(
                "<img src=\"data:"<>@post.image_type<>";base64,"<>data<>"\" width=\"200px\">"
              )
            %>
          </div>
        <% end %>
        <div class="block">
          <%= TemplateUtils.post_content(@post) %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, post: Core.get_post!(params["id"]))}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover_photo, ref)}
  end

  # cover
  @impl true
  def handle_event(
        "save",
        %{"content" => content, "status" => status, "title" => title} = _event,
        %{assigns: assigns} = socket
      ) do
    {:ok, post} =
      Core.update_post(
        assigns.post,
        %{
          title: String.trim(title),
          content: content,
          status: status
        },
        &consume_cover_photo(socket, &1)
      )

    {:noreply, assign(socket, post: post, info: "Post saved")}
  end

  # Title and content changes
  @impl true
  def handle_event(
        "update-title-and-content",
        %{"title" => title, "content" => content} = _event,
        %{assigns: assigns} = socket
      ) do
    {:ok, post} = Core.update_post(assigns.post, %{title: String.trim(title), content: content})
    {:noreply, assign(socket, post: post, info: "Post saved")}
  end

  # Status changes
  @impl true
  def handle_event(
        "update-status",
        %{"value" => new_status} = _event,
        %{assigns: assigns} = socket
      ) do
    {:ok, post} = Core.update_post(assigns.post, %{status: new_status})
    {:noreply, assign(socket, post: post, info: "Post saved")}
  end

  @impl true
  def handle_event("remove-cover-photo", _event, %{assigns: assigns} = socket) do
    {:ok, post} = Core.update_post(assigns.post, %{image: nil, image_type: nil})
    {:noreply, assign(socket, post: post, info: "Post saved")}
  end

  # sobelow_skip ["Traversal.FileModule"]
  def consume_cover_photo(socket, attrs) do
    [{binary_data, type}] =
      consume_uploaded_entries(socket, :cover_photo, fn meta, entry ->
        {File.read!(meta.path), entry.client_type}
      end)

    attrs
    |> Map.put(:image, binary_data)
    |> Map.put(:image_type, type)
  end
end
