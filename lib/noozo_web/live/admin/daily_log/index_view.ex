defmodule NoozoWeb.Admin.DailyLog.IndexView do
  @moduledoc """
  Admin daily log index live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.DailyLog
  alias Noozo.DailyLog.Entry
  alias Noozo.Pagination
  alias NoozoWeb.Admin.DailyLog.EditView

  data loading, :boolean, default: true

  @impl true
  def render(assigns) do
    ~F"""
    {#if @loading}
      <div>Loading information...</div>
    {#else}
      <div class="flex flex-col gap-6">
        <div class="flex-auto flex gap-3">
          <LivePatch to={Routes.live_path(@socket, EditView, %Entry{date: last_friday()})} class="btn">Last Friday</LivePatch>
          <LivePatch to={Routes.live_path(@socket, EditView, %Entry{date: yesterday()})} class="btn">Yesterday</LivePatch>
          <LivePatch to={Routes.live_path(@socket, EditView, %Entry{date: Timex.today()})} class="btn">Today</LivePatch>
        </div>

        <table class="">
          <thead>
            <th>Date</th>
            <th>DoW</th>
            <th>Content</th>
          </thead>
          <tbody>
            {#for entry <- @entries.entries}
              <tr>
                <td>
                  <LivePatch to={Routes.live_path(@socket, EditView, entry)} class="">{entry.date}</LivePatch>
                </td>
                <td>{entry.date |> Timex.weekday() |> Timex.day_name()}</td>
                <td>{Curtail.truncate(entry.content || "", omission: "...", length: 50)}</td>
              </tr>
            {/for}
          </tbody>
        </table>

        <Pagination source_assigns={assigns} entries={@entries} module={__MODULE__} />
      </div>
    {/if}
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
