defmodule NoozoWeb.Admin.Todo.Label.IndexView do
  @moduledoc """
  Label management
  """
  use Phoenix.LiveView

  import Noozo.Pagination

  alias Noozo.Todo
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  def render(assigns) do
    ~L"""
    <%= #live_patch "Create Label", to: Routes.live_path(@socket, CreateView)
    %>
    <div class="labels">
      <table class="table">
        <thead>
          <th>Text</th>
          <th>Text color</th>
          <th>Background color</th>
          <th>Preview</th>
        </thead>
        <tbody>
          <%= for label <- @labels.entries do %>
            <tr>
              <td>
                <form phx-change="update-title-<%= label.id %>" phx-debounce="500">
                  <input type="text" name="title" value="<%= label.title %>" phx-debounce="500" />
                </form>
              </td>
              <td>
                <form phx-change="update-text-color-<%= label.id %>" phx-debounce="500">
                  <input type="text" name="text_color_hex" value="<%= label.text_color_hex %>" phx-debounce="500" />
                </form>
              </td>
              <td>
                <form phx-change="update-color-<%= label.id %>" phx-debounce="500">
                  <input type="text" name="color_hex" value="<%= label.color_hex %>" phx-debounce="500" />
                </form>
              </td>
              <td>
                <div class="rounded-lg p-4" style="background-color: <%= label.color_hex %>; color: <%= label.text_color_hex %>">
                  <%= label.title %>
                </div>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>

    <%= live_paginate(assigns, @labels, __MODULE__, @socket) %>
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, labels: Todo.list_labels(params), params: params)}
  end

  def handle_event("update-title-" <> id, %{"title" => title} = _event, socket) do
    {:ok, _label} = Todo.update_label(id, %{title: title})
    {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}
  end

  def handle_event("update-text-color-" <> id, %{"text_color_hex" => text_color_hex} = _event, socket) do
    {:ok, _label} = Todo.update_label(id, %{text_color_hex: text_color_hex})
    {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}
  end

  def handle_event("update-color-" <> id, %{"color_hex" => color_hex} = _event, socket) do
    {:ok, _label} = Todo.update_label(id, %{color_hex: color_hex})
    {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}
  end
end
