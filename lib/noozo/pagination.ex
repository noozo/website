defmodule Noozo.Pagination do
  use NoozoWeb, :surface_func_component

  alias NoozoWeb.Endpoint

  prop source_assigns, :map, required: true
  prop entries, :struct, required: true
  prop module, :module, required: true

  def render(%{entries: []}), do: ""

  def render(
        %{
          entries: entries,
          module: module,
          source_assigns: source_assigns
        } = assigns
      ) do
    has_previous = entries.page_number > 1
    has_next = entries.page_number < entries.total_pages
    prev_page = entries.page_number - 1
    next_page = entries.page_number + 1
    params = source_assigns[:params] || %{}

    ~F"""
    <div>
      <nav class="relative z-0 inline-flex shadow-sm -space-x-px mt-6" aria-label="Pagination">
        <LivePatch
          to={Routes.live_path(Endpoint, module, Map.put(params, :page, prev_page))}
          class={"#{if has_previous, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"}
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
        </LivePatch>
        <LivePatch
          to={Routes.live_path(Endpoint, module, Map.put(params, :page, next_page))}
          class={"#{if has_next, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"}
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
        </LivePatch>
      </nav>
    </div>
    """
  end
end
