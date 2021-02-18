defmodule NoozoWeb.Admin.Todo.Board.IndexView do
  @moduledoc """
  List all the boards
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Todo
  alias NoozoWeb.Admin.Todo.Board.CreateView
  alias NoozoWeb.Admin.Todo.Board.EditView
  alias NoozoWeb.Admin.Todo.Board.ShowView
  alias NoozoWeb.Router.Helpers, as: Routes
  alias NoozoWeb.TemplateUtils

  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <%= live_patch "Create Board", to: Routes.live_path(@socket, CreateView) %>
      <div class="boards">
        <table class="table">
          <thead>
            <th>Title</th>
            <th>Rename</th>
            <th>Created at</th>
          </thead>
          <tbody>
            <%= for board <- @boards.entries do %>
              <tr>
                <td><%= live_patch board.title, to: Routes.live_path(@socket, ShowView, board.id) %>
                <td><%= live_patch "Rename", to: Routes.live_path(@socket, EditView, board.id) %></td>
                <td><%= TemplateUtils.format_date(board.inserted_at) %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <%= live_paginate(assigns, @boards, __MODULE__, @socket) %>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: true)}
  end

  def handle_info({:load_boards, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       boards: Todo.list_boards(params)
     )}
  end

  def handle_params(params, _uri, socket) do
    send(self(), {:load_boards, params})
    {:noreply, assign(socket, loading: true)}
  end
end
