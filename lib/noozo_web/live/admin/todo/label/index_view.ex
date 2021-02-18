defmodule NoozoWeb.Admin.Todo.Label.IndexView do
  @moduledoc """
  Label management
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Todo
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  def render(assigns) do
    ~L"""
    <div class="mb-6">
      <span class="btn cursor-pointer" phx-click="create-label">Create label</span>
    </div>
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

  def handle_event(
        "update-text-color-" <> id,
        %{"text_color_hex" => text_color_hex} = _event,
        socket
      ) do
    {:ok, _label} = Todo.update_label(id, %{text_color_hex: text_color_hex})
    {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}
  end

  def handle_event("update-color-" <> id, %{"color_hex" => color_hex} = _event, socket) do
    {:ok, _label} = Todo.update_label(id, %{color_hex: color_hex})
    {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}
  end

  def handle_event("create-label", _event, socket) do
    case Todo.create_label(%{title: "new label", color_hex: "#ffffff"}) do
      {:ok, _label} ->
        {:noreply, assign(socket, labels: Todo.list_labels(socket.assigns.params))}

      _ ->
        {:noreply,
         put_flash(socket, :error, "Default label already exists. Rename to create another.")}
    end
  end
end
