defmodule Noozo.Pagination do
  @moduledoc """
  Live Pagination module
  """
  use Phoenix.Component

  alias NoozoWeb.Endpoint

  attr :source_assigns, :map, required: true
  attr :entries, :any, required: true
  attr :module, :atom, required: true

  def render(%{entries: []}), do: ""

  def render(
        %{
          entries: entries,
          module: _module,
          source_assigns: source_assigns
        } = assigns
      ) do
    assigns =
      assigns
      |> assign(:has_previous, entries.page_number > 1)
      |> assign(:has_next, entries.page_number < entries.total_pages)
      |> assign(:prev_page, entries.page_number - 1)
      |> assign(:next_page, entries.page_number + 1)
      |> assign(:params, source_assigns[:params] || %{})

    ~H"""
    <div>
      <nav class="relative z-0 inline-flex shadow-sm -space-x-px mt-6" aria-label="Pagination">
        <.link
          navigate={Routes.live_path(Endpoint, @module, Map.put(@params, :page, @prev_page))}
          class={"#{if @has_previous, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"}
        >
          <span>Newer</span>
          <!-- Heroicon name: chevron-left -->
          <svg
            class="h-5 w-5"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
              clip-rule="evenodd"
            />
          </svg>
        </.link>
        <.link
          navigate={Routes.live_path(Endpoint, @module, Map.put(@params, :page, @next_page))}
          class={"#{if @has_next, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"}
        >
          <span>Older</span>
          <!-- Heroicon name: chevron-right -->
          <svg
            class="h-5 w-5"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
              clip-rule="evenodd"
            />
          </svg>
        </.link>
      </nav>
    </div>
    """
  end
end
