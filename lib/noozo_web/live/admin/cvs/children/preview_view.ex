defmodule NoozoWeb.Admin.Cvs.Children.PreviewView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}

  alias Noozo.Cvs
  alias Noozo.Cvs.Cv
  alias Noozo.Cvs.CvSectionItem

  alias Timex.Format.Duration.Formatters.Humanized, as: HumanizedDuration

  def render(assigns) do
    ~H"""
    <div class="prose max-w-full sm:ml-6 sm:mr-6">
      <div class="pt-12 border-b-2 border-gray-100 pb-10">
        <div class="sm:float-left inline mt-10">
          <div class="sm:text-left text-center sm:text-6xl text-3xl font-bold mb-4"><%= @cv.title %></div>
          <div class="sm:text-left text-center sm:text-3xl text-xl pl-1"><%= @cv.subtitle %></div>
        </div>

        <div class="mt-10">
          <%= for item <- @cv.header_items do %>
            <div class="text-center sm:text-right">
              <%= Phoenix.HTML.raw(item.content) %>
            </div>
          <% end %>
        </div>
      </div>

      <div class="mt-12 border-b-2 border-gray-100 pb-10 flex flex-row gap-6 items-center">
        <%= if @cv.image do %>
          <div class="rounded-xl">
            <img class="w-48" alt={@cv.title} src={Cv.image_url(@cv)} />
          </div>
        <% end %>
        <%= if @cv.abstract do %>
          <div class="flex-grow">
            <%= @cv.abstract |> String.replace("\n", "<br/>")  |> Phoenix.HTML.raw() %>
          </div>
        <% end %>
      </div>

      <%= for section <- @cv.sections do %>
        <div class="border-b-2 border-gray-100">
          <div class="text-center mt-12 mb-12 text-3xl font-bold"><%= Phoenix.HTML.raw(section.title) %></div>

          <%= for item <- section.items do %>
            <div class="grid grid-cols-5 gap-4 mb-8">
              <div class="col-span-1 md:block hidden">
                <%= render_dates_and_image(@socket.assigns, item) %>
              </div>

              <div class="md:col-span-4 col-span-5">
                <%= if item.title do %>
                  <div class="text-2xl font-bold"><%= Phoenix.HTML.raw(item.title) %></div>
                <% end %>

                <%= if item.subtitle do %>
                  <div class="text-sm pb-4">
                    <%= Phoenix.HTML.raw(item.subtitle) %>
                    <span class="block md:hidden">
                      <%= render_dates_and_image(@socket.assigns, item) %>
                    </span>
                  </div>
                <% end %>

                <div class="mb-4">
                  <%= item.content |> String.replace("\n", "<br/>")  |> Phoenix.HTML.raw() %>
                </div>

                <%= if item.footer do %>
                  <div class="mb-2 text-sm pt-4">
                    <%= item.footer |> String.replace("\n", "<br/>")  |> Phoenix.HTML.raw() %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, %{"cv_uuid" => cv_uuid} = _session, socket) do
    Cvs.subscribe()
    cv = Cvs.get_full_cv!(cv_uuid)
    {:ok, assign(socket, %{cv: cv})}
  end

  def handle_info({_event, _item}, socket) do
    cv = Cvs.get_full_cv!(socket.assigns.cv.uuid)
    {:noreply, assign(socket, :cv, cv)}
  end

  defp month_year(nil), do: nil

  defp month_year(date) do
    Timex.format!(date, "{Mshort} {YYYY}")
  end

  defp duration(nil, nil), do: nil
  defp duration(nil, _date_to), do: nil
  defp duration(date_from, nil), do: duration(date_from, Timex.today())

  # sobelow_skip ["XSS.Raw"]
  defp duration(date_from, date_to) do
    string =
      date_from
      |> Date.diff(date_to)
      |> Timex.Duration.from_days()
      |> HumanizedDuration.format()

    """
    <div class="text-black text-xs">#{string}</div>
    """
    |> Phoenix.HTML.raw()
  end

  defp render_dates_and_image(assigns, item) do
    ~H"""
    <%= if item.date_from || item.date_to do %>
      <span class="font-bold">
        <%= month_year(item.date_from) %> to
        <%= month_year(item.date_to) || "present day" %>
      </span>
      <%= duration(item.date_from, item.date_to) %>
    <% end %>
    <%= if item.image do %>
      <div class="flex flex-wrap justify-center">
        <img alt={item.title} src={CvSectionItem.image_url(item)} />
      </div>
    <% end %>
    """
  end
end
