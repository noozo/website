defmodule Admin.Components.TagEditor do
  @moduledoc """
  Tag editor component
  """
  use Phoenix.LiveComponent

  alias Noozo.Core

  def render(assigns) do
    ~L"""
    <div class="block shadow sm:rounded-md sm:overflow-hidden mb-4" id="<%= @id %>">
      <div class="flex items-baseline mt-4">
        <div class="space-x-2 flex">
          <%= for tag <- @post.tags do %>
            <div class="ml-4 text-xs inline-flex items-center font-bold leading-sm uppercase px-3 py-1 rounded-full bg-white text-gray-700 border">
              <%= tag.name %>
              <a class="cursor-pointer ml-4 text-xs inline-flex items-center font-bold leading-sm uppercase px-3 py-1 rounded-full bg-white text-gray-700 border"
                 phx-click="remove"
                 phx-value-tag_id="<%= tag.id %>"
                 phx-target="<%= @myself %>">X</a>
            </div>
          <% end %>
        </div>
      </div>
      <form phx-submit="add" phx-change="suggest" phx-target="<%= @myself %>">
        <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
          <div class="grid grid-cols-6 gap-6">
            <div class="col-span-6 sm:col-span-3">
              <label for="tags">
                Tags
              </label>
              <div class="mt-1">
                <input type='text' name='new_tag' size="5" />
              </div>
            </div>

            <div class="col-span-6 sm:col-span-3">
              <%= Enum.join(@suggestions, ", ") %>
            </div>

            <div class="col-span-6 sm:col-span-3">
              <div class="mt-1">
                <button class="btn" class="btn btn-success">Add tag</button>
              </div>
            </div>
          </div>
        </div>
      </form>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, suggestions: [])}
  end

  def handle_event("remove", %{"tag_id" => tag_id} = _event, socket) do
    post_id = socket.assigns.post.id
    Core.delete_tagging!(tag_id, post_id)
    {:noreply, assign(socket, post: Core.get_post!(post_id), suggestions: [])}
  end

  def handle_event("add", %{"new_tag" => tag_name}, socket) do
    post_id = socket.assigns.post.id
    {:ok, _tagging} = Core.tag_post!(tag_name, post_id)
    {:noreply, assign(socket, post: Core.get_post!(post_id), suggestions: [])}
  end

  def handle_event("suggest", %{"new_tag" => tag_name}, socket) do
    suggestions =
      case String.trim(tag_name) do
        nil -> []
        "" -> []
        tag_name -> Enum.map(Core.suggest_tags(tag_name), fn t -> t.name end)
      end

    {:noreply, assign(socket, post: socket.assigns.post, suggestions: suggestions)}
  end
end
