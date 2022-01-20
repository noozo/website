defmodule NoozoWeb.Experiments.Games.Memory.MainView do
  use Phoenix.LiveView, layout: {NoozoWeb.LayoutView, "live.html"}
  alias NoozoWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~H"""
    <div class="content">
      <div class="row">
      Game ended: <%= @game_ended %>
      </div>
      <div class="row">
        <%= for {element, index} <- Enum.with_index(@elements) do %>
          <div class="column column-40">
            <%= if element.found do %>
              <img src="<%= element.src %>" width="100" height="100" />
            <% else %>
              <img src="<%= Routes.static_path(@socket, "/images/experiments/games/memory/question.png") %>" width="100" height="100"
                 phx-click="clicked_element" phx-value-element_id="<%= element.id %>" />
            <% end %>
          </div>
          <%= if index == 3 do %>
            </div><div class="row">
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    {:ok, assign(socket, setup_game_data(socket, params["theme"] || ""))}
  end

  def handle_event("clicked_element", %{"element_id" => id} = _event, socket) do
    id = String.to_integer(id)
    elements = socket.assigns.elements
    [clicked_element] = Enum.filter(elements, &(&1.id == id))

    cond do
      # Is game over? or paused
      socket.assigns.game_ended == true or socket.assigns.game_paused ->
        IO.puts("Game is over or paused")
        {:noreply, socket}

      # If there is one selected and we click the same one, do nothing
      socket.assigns.selected_id != nil and socket.assigns.selected_id == id ->
        IO.puts("Second click, same object")
        {:noreply, socket}

      # There's is one already selected, check if the new one has same value
      socket.assigns.selected_id != nil ->
        IO.puts("Second click, another object")
        process_second_click(socket, elements, clicked_element)

      # Nothing is currently selected, so track that
      true ->
        IO.puts("First click")
        process_first_click(socket, elements, clicked_element)
    end
  end

  def handle_info({:click_timeout, id}, socket) do
    elements = socket.assigns.elements

    # Hide the element again if the timeout fired
    elements = update_element_found(elements, id, false)

    {:noreply,
     assign(socket,
       elements: elements,
       selected_id: nil,
       selected_value: nil
     )}
  end

  def handle_info({:hide_elements, id1, id2}, socket) do
    elements =
      socket.assigns.elements
      |> update_element_found(id1, false)
      |> update_element_found(id2, false)

    {:noreply,
     assign(socket,
       game_paused: false,
       elements: elements,
       selected_id: nil,
       selected_value: nil
     )}
  end

  defp process_first_click(socket, elements, clicked_element) do
    elements = update_element_found(elements, clicked_element.id, true)

    show_timer_ref = Process.send_after(self(), {:click_timeout, clicked_element.id}, 1_000)

    {:noreply,
     assign(socket,
       elements: elements,
       selected_id: clicked_element.id,
       selected_value: clicked_element.value,
       show_timer_ref: show_timer_ref
     )}
  end

  defp process_second_click(socket, elements, clicked_element) do
    # Cancel the existing show timer, if any
    Process.cancel_timer(socket.assigns.show_timer_ref)
    # Show the newly clicked element
    elements = update_element_found(elements, clicked_element.id, true)
    # If values match for both, don't do anything
    # Otherwise, set a timer to hide them
    game_paused =
      if socket.assigns.selected_value != clicked_element.value do
        Process.send_after(
          self(),
          {:hide_elements, clicked_element.id, socket.assigns.selected_id},
          1_000
        )

        true
      else
        false
      end

    {:noreply,
     assign(socket,
       game_paused: game_paused,
       game_ended: check_game_ended(elements),
       elements: elements,
       selected_id: nil,
       selected_value: nil,
       show_timer_ref: nil
     )}
  end

  defp check_game_ended(elements) do
    elements
    |> Enum.reduce(true, fn e, acc -> acc and e.found end)
  end

  defp setup_game_data(socket, theme) do
    elements =
      [
        %{
          id: 1,
          value: 1,
          src: Routes.static_path(socket, "/images/experiments/games/memory/1#{theme}.jpg"),
          found: false
        },
        %{
          id: 2,
          value: 2,
          src: Routes.static_path(socket, "/images/experiments/games/memory/2#{theme}.jpg"),
          found: false
        },
        %{
          id: 3,
          value: 3,
          src: Routes.static_path(socket, "/images/experiments/games/memory/3#{theme}.jpg"),
          found: false
        },
        %{
          id: 4,
          value: 4,
          src: Routes.static_path(socket, "/images/experiments/games/memory/4#{theme}.jpg"),
          found: false
        },
        %{
          id: 5,
          value: 1,
          src: Routes.static_path(socket, "/images/experiments/games/memory/1#{theme}.jpg"),
          found: false
        },
        %{
          id: 6,
          value: 2,
          src: Routes.static_path(socket, "/images/experiments/games/memory/2#{theme}.jpg"),
          found: false
        },
        %{
          id: 7,
          value: 3,
          src: Routes.static_path(socket, "/images/experiments/games/memory/3#{theme}.jpg"),
          found: false
        },
        %{
          id: 8,
          value: 4,
          src: Routes.static_path(socket, "/images/experiments/games/memory/4#{theme}.jpg"),
          found: false
        }
      ]
      |> Enum.shuffle()

    %{
      selected_id: nil,
      selected_value: nil,
      game_ended: false,
      game_paused: false,
      elements: elements
    }
  end

  defp update_element_found(elements, id, new_state) do
    [source_element] = Enum.filter(elements, &(&1.id == id))

    new_element = Map.put(source_element, :found, new_state)

    Enum.map(elements, fn e ->
      if e.id == id, do: new_element, else: e
    end)
  end
end
