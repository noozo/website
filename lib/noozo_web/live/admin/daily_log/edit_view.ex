defmodule NoozoWeb.Admin.DailyLog.EditView do
  @moduledoc """
  Admin daily log edit live view
  """
  use NoozoWeb, :surface_view

  alias Noozo.DailyLog
  alias NoozoWeb.Admin.DailyLog.IndexView

  @impl true
  def render(assigns) do
    ~F"""
    <div class="flex flex-col gap-6">
      <div>
        <LivePatch to={Routes.live_path(@socket, IndexView)} class="btn">Back to list</LivePatch>
      </div>

      <div class="pros">
        <h2 class="block text-lg font-medium text-black">
          {@entry.date |> Timex.weekday() |> Timex.day_name()}
          {@entry.date}
        </h2>
      </div>

      <div class="shadow sm:rounded-md border block">
        <form phx-change="save" phx-debounce="1000">
          <div class="px-4 py-5 bg-white space-y-6 sm:p-6">
            <div class="flex flex-row flex-wrap gap-6">
              <div class="">
                <label for="content">
                  Content
                </label>
                <div class="mt-1">
                  <textarea id="content" name="content" rows="15" cols="50" phx-debounce="1000">
                    {@entry.content}
                  </textarea>
                </div>
              </div>

              <div class="col-span-6 sm:col-span-3 border-2 border-dashed border-gray-200 p-4 prose w-96">
                <div class="block text-sm text-gray-700">
                  {(@entry.content || "") |> Earmark.as_html!() |> Phoenix.HTML.raw()}
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, entry: DailyLog.find_or_create(params["date"]))}
  end

  @impl true
  def handle_event(
        "save",
        %{"_target" => _target, "content" => content} = _event,
        socket
      ) do
    {:ok, entry} =
      DailyLog.update_entry(socket.assigns.entry, %{
        content: String.trim_leading(content)
      })

    {:noreply,
     assign(socket,
       entry: entry
     )}
  end
end
