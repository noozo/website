defmodule Noozo.Pagination do
  alias NoozoWeb.Router.Helpers, as: Routes

  import Phoenix.LiveView.Helpers

  @moduledoc """
    Pagination utils
  """
  def live_paginate(_assigns, %{entries: []} = _struct, _live_module, _socket), do: ""

  def live_paginate(assigns, struct, live_module, socket) do
    has_previous = struct.page_number > 1
    has_next = struct.page_number < struct.total_pages
    prev_page = struct.page_number - 1
    next_page = struct.page_number + 1
    params = assigns[:params] || %{}

    ~H"""
      <div>
        <nav class="relative z-0 inline-flex shadow-sm -space-x-px mt-6" aria-label="Pagination">
          <%= Phoenix.LiveView.Helpers.live_patch to: Routes.live_path(socket, live_module, Map.put(params, :page, prev_page)),
              class: "#{if has_previous, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              do %>
            <span>Newer</span>
            <!-- Heroicon name: chevron-left -->
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          <% end %>
          <%= Phoenix.LiveView.Helpers.live_patch to: Routes.live_path(socket, live_module,Map.put(params, :page, next_page)),
              class: "#{if has_next, do: "", else: "opacity-50"} relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              do %>
            <span>Older</span>
            <!-- Heroicon name: chevron-right -->
            <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          <% end %>
        </nav>
      </div>
    """
  end
end
