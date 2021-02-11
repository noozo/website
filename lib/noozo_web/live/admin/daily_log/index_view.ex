defmodule NoozoWeb.Admin.DailyLog.IndexView do
  @moduledoc """
  Admin daily log index live view
  """
  use Phoenix.LiveView

  import Noozo.Pagination

  alias Noozo.DailyLog
  alias Noozo.DailyLog.Entry
  alias NoozoWeb.Admin.DailyLog.EditView
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <div class=" flex flex-col gap-6">
        <div class="flex-auto flex gap-3">
          <%= live_patch "Last Friday", to: Routes.live_path(@socket, EditView, %Entry{date: last_friday()}), class: "btn" %>
          <%= live_patch "Yesterday", to: Routes.live_path(@socket, EditView, %Entry{date: yesterday()}), class: "btn" %>
          <%= live_patch "Today", to: Routes.live_path(@socket, EditView, %Entry{date: Timex.today()}), class: "btn" %>
        </div>

        <table class="">
          <thead>
            <th>Date</th>
            <th>DoW</th>
            <th>Content</th>
          </thead>
          <tbody>
            <%= for entry <- @entries.entries do %>
              <tr>
                <td><%= live_patch entry.date, to: Routes.live_path(@socket, EditView, entry) %></td>
                <td><%= entry.date |> Timex.weekday() |> Timex.day_name() %></td>
                <td><%= Curtail.truncate((entry.content || ""), omission: "...", length: 50) %></td>
              </tr>
            <% end %>
          </tbody>
        </table>

        <%= live_paginate(assigns, @entries, __MODULE__, @socket) %>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: true)}
  end

  def handle_info({:load_entries, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       entries: DailyLog.list_entries(params)
     )}
  end

  def handle_params(params, _uri, socket) do
    send(self(), {:load_entries, params})
    {:noreply, assign(socket, loading: true)}
  end

  defp last_friday, do: last_friday(Timex.today())

  defp last_friday(reference) do
    if Timex.weekday(reference) == 5 do
      reference
    else
      reference |> day_before() |> last_friday()
    end
  end

  defp yesterday, do: day_before()
  defp day_before, do: day_before(Timex.today())
  defp day_before(reference), do: reference |> Timex.shift(days: -1)
end
