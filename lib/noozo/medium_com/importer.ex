defmodule Noozo.MediumCom.Importer do
  @moduledoc """
  Module that imports posts from medium
  """
  alias Noozo.Core
  alias Noozo.Repo

  require Logger

  def import(username) do
    Logger.info("Getting posts from medium")

    username
    |> fetch_data_from_medium()
    |> parse_rss_data()
    |> save_posts()
  end

  defp fetch_data_from_medium(username) do
    HTTPoison.start()
    {:ok, response} = HTTPoison.get("https://medium.com/feed/#{username}")
    response.body
  end

  defp parse_rss_data(xml_string) do
    xml_string
    |> ElixirFeedParser.parse()
    |> Map.get(:entries)
    |> Enum.filter(fn entry ->
      entry.author == "Pedro Assunção" and length(entry.categories) > 0
    end)
    |> Enum.map(fn entry ->
      %{
        id_url: entry.id,
        published_at: Timex.parse!(entry[:"rss2:pubDate"], "{RFC1123}"),
        title: entry.title,
        content: entry.content,
        tags: entry.categories
      }
    end)
  end

  defp save_posts(posts) do
    posts
    |> Enum.reject(&Core.post_has_been_imported_from_medium?(&1.id_url))
    |> Enum.each(&save_post/1)
  end

  defp save_post(post_data) do
    Repo.transaction(fn ->
      {:ok, post} =
        Core.create_post(%{
          title: post_data.title,
          content: post_data.content,
          published_at: post_data.published_at,
          status: "published"
        })

      Enum.each(post_data.tags, &Core.tag_post!(&1, post.id))
      {:ok, _history_entry} = Core.mark_post_as_imported_from_medium(post_data.id_url)
      IO.puts("Saved medium post: #{post_data.id_url}")
    end)
  end
end
