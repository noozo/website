defmodule Admin.Components.TitleSuggester do
  @moduledoc """
  Title suggester component
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="block shadow sm:rounded-md sm:overflow-hidden mb-4 p-6" id={@id}>
      <p><span class="text-gray-400">Tag suggestions:</span> <%= @suggested_title %></p>
    </div>
    """
  end

  def update(%{id: id, post: post} = _assigns, socket) do
    {:ok, assign(socket, id: id, suggested_title: suggestion(post.content))}
  end

  defp suggestion(content) do
    clean = HtmlSanitizeEx.strip_tags(content)

    case topics(clean) do
      nil -> "N/A"
      suggestion -> suggestion
    end
  end

  defp topics(text) do
    case text do
      nil ->
        nil

      text ->
        text
        |> remove_punctuation()
        |> convert_to_list()
        |> remove_simple_words()
        |> count_occurrences()
        |> pick_top_results()
        |> convert_to_text()
    end
  end

  defp remove_punctuation(text) do
    text
    |> String.downcase()
    |> String.replace("\r", " ")
    |> String.replace("\n", " ")
    |> String.replace(",", " ")
    |> String.replace(".", " ")
    |> String.replace("!", " ")
    |> String.replace("?", " ")
    |> String.replace(")", " ")
    |> String.replace("(", " ")
    |> String.replace("[", " ")
    |> String.replace("]", " ")
    |> String.replace("\"", " ")
    |> String.replace("'", " ")
    |> String.replace("+", " ")
    |> String.replace("{", " ")
    |> String.replace("}", " ")
    |> String.replace(":", " ")
    |> String.replace(";", " ")
    |> String.replace("#", " ")
    |> String.replace("%", " ")
    |> String.replace("&", " ")
    |> String.replace("-", " ")
    |> String.replace("=", " ")
    |> String.replace("\\", " ")
    |> String.replace("/", " ")
    |> String.replace("$", " ")
  end

  defp convert_to_list(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn x -> String.trim(x) != "" end)
  end

  defp remove_simple_words(list) do
    [{_key, ignore_words}] = :ets.lookup(:memory_cache, "ignore_words")

    list
    |> Enum.filter(fn w -> !Enum.any?(ignore_words, fn x -> x == w end) end)
    |> Enum.filter(fn w -> String.length(w) > 2 end)
  end

  defp count_occurrences(list) do
    list
    |> Enum.reduce(%{}, fn w, acc -> Map.put(acc, w, Map.get(acc, w, 0) + 1) end)
    |> Enum.map(fn {k, v} -> {k, v} end)
  end

  defp pick_top_results(map) do
    map
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.reverse()
    |> Enum.slice(0..4)
  end

  defp convert_to_text(list) do
    list
    |> Enum.map(fn {k, _v} -> k end)
    |> Enum.join(", ")
  end
end
