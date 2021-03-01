defmodule NoozoWeb.Admin.Analytics.IndexView do
  @moduledoc """
  List all the boards
  """
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  import Noozo.Pagination

  alias Noozo.Analytics
  alias NoozoWeb.Router.Helpers, as: Routes
  alias Timex.Duration

  def render(assigns) do
    ~L"""
    <nav class="navbar" role="navigation" aria-label="main navigation">
      <div class="flex-auto flex space-x-3 max-w-7xl mb-6">
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="today">Today</a>
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="yesterday">Yesterday</a>
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="week">Last 7 days</a>
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="fortnite">Last 15 days</a>
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="month">Last month</a>
        <a class="btn" href="#" phx-click="change_dates" phx-value-value="year">Last year</a>
      </div>
    </nav>

    <form phx-submit="update">
      <div class="shadow sm:rounded-md sm:overflow-hidden">
        <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
          <div class="grid grid-cols-6 gap-6">
            <div class="col-span-6 sm:col-span-3">
              <label for="content">
                Start date
              </label>
              <div class="mt-1">
                <input class="input" type="text" name="start_date" value="<%= @start_date |> Timex.format!("{ISOdate}") %>" />
              </div>
            </div>

            <div class="col-span-6 sm:col-span-3">
              <label for="content">
                End date
              </label>
              <div class="mt-1">
                <input class="input" type="text" name="end_date" value="<%= @end_date |> Timex.format!("{ISOdate}") %>" />
              </div>
            </div>

            <div class="col-span-6 sm:col-span-3">
              <label for="content">
                Chart by
              </label>
              <div class="mt-1">
                <div class="select">
                  <select name="sort_by">
                    <option value="day" <%= if @sort_by == :day, do: "selected" %>>Day</option>
                    <option value="week" <%= if @sort_by == :week, do: "selected" %>>Week</option>
                    <option value="month" <%= if @sort_by == :month, do: "selected" %>>Month</option>
                    <option value="year" <%= if @sort_by == :year, do: "selected" %>>Year</option>
                  </select>
                </div>
              </div>
            </div>

            <div class="col-span-6 sm:col-span-3">
              <div class="mt-1">
                <input class="btn" type="submit" value="Update" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </form>

    <br />

    <div id="analytics-diagram"
         phx-hook="AnalyticsDiagram"
         data-analytics-data="<%= serialize(@all_entries, @sort_by) %>"></div>

    <h2>Total count: <%= @total_count %></h2>
    <%= if is_nil(@path) or @path == "" do %>
      <div class="flex flex-col mt-6">
        <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
            <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
              <table>
                <thead>
                  <tr>
                    <th scope="col">
                      URL
                    </th>
                    <th scope="col">
                      Count
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <%= for entry <- @paginated_entries do %>
                    <tr>
                      <td>
                        <a phx-click="view_path" phx-value-value="<%= entry.path %>" href="#">
                          <%= entry.path %>
                        </a>
                      </td>
                      <td>
                        <%= entry.counter %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <%= live_paginate(assigns, @paginated_entries, __MODULE__, @socket) %>
    <% else %>
      <h2><%= @path %></h2>
      <p><a phx-click="view_path" phx-value-value="" href="#">view all</a></p>
    <% end %>
    """
  end

  def mount(params, _session, socket) do
    {start_date, end_date, sort_by, path} = parse_params(params)

    {:ok,
     assign(socket,
       all_entries: Analytics.list_entries(start_date, end_date, path),
       paginated_entries: Analytics.paginated_entries(start_date, end_date, params),
       total_count: Analytics.count_entries(start_date, end_date, path),
       sort_by: sort_by,
       start_date: start_date,
       end_date: end_date,
       path: path
     )}
  end

  def handle_params(params, _uri, socket) do
    {start_date, end_date, sort_by, path} = parse_params(params)

    {:noreply,
     assign(socket,
       all_entries: Analytics.list_entries(start_date, end_date, path),
       paginated_entries: Analytics.paginated_entries(start_date, end_date, params),
       total_count: Analytics.count_entries(start_date, end_date, path),
       sort_by: sort_by,
       start_date: start_date,
       end_date: end_date,
       path: path
     )}
  end

  def handle_event(
        "update",
        %{"start_date" => _start_date, "end_date" => _end_date, "sort_by" => _sort_by} = event,
        socket
      ) do
    {start_date, end_date, sort_by, _path} = parse_params(event)

    {:noreply,
     push_redirect(
       socket,
       to:
         Routes.live_path(socket, NoozoWeb.Admin.Analytics.IndexView,
           start_date: start_date |> Timex.format!("{ISOdate}"),
           end_date: end_date |> Timex.format!("{ISOdate}"),
           sort_by: sort_by,
           path: socket.assigns.path
         )
     )}
  end

  def handle_event("view_path", %{"value" => path} = _event, socket) do
    {:noreply,
     push_redirect(
       socket,
       to:
         Routes.live_path(socket, NoozoWeb.Admin.Analytics.IndexView,
           start_date: socket.assigns.start_date |> Timex.format!("{ISOdate}"),
           end_date: socket.assigns.end_date |> Timex.format!("{ISOdate}"),
           sort_by: socket.assigns.sort_by,
           path: path
         )
     )}
  end

  def handle_event("change_dates", %{"value" => "today"}, socket),
    do: redirect(socket, Timex.now(), Timex.now() |> Timex.add(Duration.from_days(1)))

  def handle_event("change_dates", %{"value" => "yesterday"}, socket),
    do: redirect(socket, Timex.now() |> Timex.subtract(Duration.from_days(1)), Timex.now())

  def handle_event("change_dates", %{"value" => "week"}, socket),
    do:
      redirect(
        socket,
        Timex.now() |> Timex.subtract(Duration.from_days(7)),
        Timex.now() |> Timex.add(Duration.from_days(1))
      )

  def handle_event("change_dates", %{"value" => "fortnite"}, socket),
    do:
      redirect(
        socket,
        Timex.now() |> Timex.subtract(Duration.from_days(15)),
        Timex.now() |> Timex.add(Duration.from_days(1))
      )

  def handle_event("change_dates", %{"value" => "month"}, socket),
    do:
      redirect(
        socket,
        Timex.now() |> Timex.subtract(Duration.from_days(30)),
        Timex.now() |> Timex.add(Duration.from_days(1))
      )

  def handle_event("change_dates", %{"value" => "year"}, socket),
    do:
      redirect(
        socket,
        Timex.now() |> Timex.subtract(Duration.from_days(364.5)),
        Timex.now() |> Timex.add(Duration.from_days(1))
      )

  defp redirect(socket, start_date, end_date) do
    {:noreply,
     push_redirect(
       socket,
       to:
         Routes.live_path(socket, NoozoWeb.Admin.Analytics.IndexView,
           start_date: start_date |> Timex.format!("{ISOdate}"),
           end_date: end_date |> Timex.format!("{ISOdate}"),
           sort_by: socket.assigns.sort_by,
           path: socket.assigns.path
         )
     )}
  end

  defp serialize(entries, sort_by) do
    entries
    |> Enum.map(&Map.take(&1, [:path, :date, :counter]))
    |> sort(sort_by)
    |> Enum.map(fn {date, entries} ->
      {date, Enum.reduce(entries, 0, &(&1.counter + &2))}
    end)
    |> Map.new()
    |> Jason.encode!()
  end

  defp sort(data, :day) do
    data
    |> Enum.sort_by(&Map.get(&1, :date), &<=/2)
    |> Enum.group_by(&Map.get(&1, :date))
  end

  defp sort(data, :week) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0Wiso}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0Wiso}")))
  end

  defp sort(data, :month) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0M}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0M}")))
  end

  defp sort(data, :year) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}")))
  end

  defp parse_params(params) do
    start_date =
      if params["start_date"] do
        Timex.parse!(params["start_date"], "{ISOdate}")
      else
        Timex.now() |> Timex.subtract(Duration.from_weeks(4.5)) |> Timex.to_date()
      end

    end_date =
      if params["end_date"] do
        Timex.parse!(params["end_date"], "{ISOdate}")
      else
        Timex.now() |> Timex.add(Duration.from_days(1)) |> Timex.to_date()
      end

    sort_by =
      if params["sort_by"] do
        String.to_existing_atom(params["sort_by"])
      else
        :day
      end

    {start_date, end_date, sort_by, params["path"]}
  end
end
