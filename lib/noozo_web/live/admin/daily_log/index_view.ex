defmodule NoozoWeb.Admin.DailyLog.IndexView do
  @moduledoc """
  Admin daily log index live view
  """
  use NoozoWeb, :live_view

  alias Noozo.DailyLog
  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <div>Loading information...</div>
    <% else %>
      <div class="flex flex-col gap-6">
        <div class="flex-auto flex gap-3">
          <.link navigate={~p"/admin/log/#{Date.to_string(last_friday())}"} class="btn">Last Friday</.link>
          <.link navigate={~p"/admin/log/#{Date.to_string(yesterday())}"} class="btn">Yesterday</.link>
          <.link navigate={~p"/admin/log/#{Date.to_string(Timex.today())}"} class="btn">Today</.link>
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
                <td>
                  <.link navigate={~p"/admin/log/#{Date.to_string(entry.date)}"} class=""><%= entry.date %></.link>
                </td>
                <td><%= entry.date |> Timex.weekday() |> Timex.day_name() %></td>
                <td><%= String.slice(entry.content || "", 0, 50) <> "..." %></td>
              </tr>
            <% end %>
          </tbody>
        </table>

        <%= Noozo.Pagination.render(%{source_assigns: assigns, entries: @entries, module: __MODULE__}) %>
      </div>
    <% end %>
    """
  end

  @impl true
  def handle_info({:load_entries, params}, socket) do
    {:noreply,
     assign(socket,
       loading: false,
       entries: DailyLog.list_entries(params)
     )}
  end

  @impl true
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
