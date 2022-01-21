defmodule NoozoWeb.Admin.Page.EditView do
  @moduledoc """
  Admin pages edit live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.Core
  alias NoozoWeb.Admin.Page.IndexView

  data info, :string
  data error, :string

  @impl true
  def render(assigns) do
    ~F"""
    {live_patch("Back to list", to: Routes.live_path(@socket, IndexView), class: "btn")}

    <div class="flex-none p-5">
      {#unless is_nil(@info)}
        <div class="shadow p-5 bg-green-300 rounded-md" role="alert">{@info}</div>
      {/unless}
      {#unless is_nil(@error)}
        <div class="shadow p-5 bg-red-300 rounded-md" role="alert">{@error}</div>
      {/unless}
    </div>

    <div class="mt-5 md:mt-0 flex flex-row gap-6">
      <div class="mt-5 md:mt-0 flex flex-col">
        <form class="mb-6 flex-grow" phx-change="save" phx-debounce="500">
          <div class="shadow sm:rounded-md sm:overflow-hidden">
            <div class="px-4 py-5 bg-white space-y-6 sm:p-6 flex flex-col gap-6">
              <div>
                <label for="title">
                  Title
                </label>
                <div class="mt-1">
                  <input type="text" name="title" value={@page.title} phx-debounce="5000">
                </div>
              </div>

              <div>
                <label for="content">
                  Content
                </label>
                <div class="mt-1">
                  <textarea class="w-full" type="text" name="content" rows="20" cols="70" phx-debounce="5000">
                    {@page.content}
                  </textarea>
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>

      <div class="w-1/2 border-2 border-dashed border-gray-200 p-4 prose lg:prose-xl">
        <h2 class="title">{@page.title}</h2>
        <div class="block">
          {@page.content |> Phoenix.HTML.raw()}
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:info, nil)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, page: Core.get_page!(params["id"]))}
  end

  @impl true
  def handle_event(
        "save",
        %{"_target" => _target, "title" => title, "content" => content} = _event,
        socket
      ) do
    {:ok, page} =
      Core.update_page(socket.assigns.page, %{
        title: String.trim(title),
        content: String.trim(content)
      })

    {:noreply,
     assign(socket,
       page: page,
       info: "Page saved"
     )}
  end
end
