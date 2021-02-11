defmodule NoozoWeb.FeedController do
  @moduledoc """
  Controller responsible for generating site RSS feed
  """
  use NoozoWeb, :controller
  alias Atomex.{Entry, Feed}
  alias Noozo.Core
  plug Ueberauth

  def index(conn, params) do
    feed_content = params |> Core.list_posts(true) |> build_feed()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, feed_content)
  end

  defp build_feed(posts) do
    has_previous = posts.page_number > 1
    has_next = posts.page_number < posts.total_pages
    prev_page = posts.page_number - 1
    next_page = posts.page_number + 1

    feed =
      Feed.new(
        "https://pedroassuncao.com",
        DateTime.utc_now(),
        "Pedro Assunção - Software Developer"
      )
      |> Feed.author("Pedro Assunção", email: "pedro@pedroassuncao.com")
      |> Feed.link("https://pedroassuncao.com/feed", rel: "first")
      |> Feed.link("https://pedroassuncao.com/feed?page=#{posts.page_number}", rel: "self")
      |> Feed.link("https://pedroassuncao.com/feed?page=#{posts.total_pages}", rel: "last")
      |> Feed.entries(Enum.map(posts, &get_entry/1))

    feed =
      if has_previous do
        Feed.link(feed, "https://pedroassuncao.com/feed?page=#{prev_page}", rel: "previous")
      else
        feed
      end

    feed =
      if has_next do
        Feed.link(feed, "https://pedroassuncao.com/feed?page=#{next_page}", rel: "next")
      else
        feed
      end

    feed
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp get_entry(%{id: id, title: title, content: content, created_at: created_at} = _post) do
    "https://pedroassuncao.com/posts/#{id}"
    |> Entry.new(created_at, title)
    |> Entry.content(content, type: "html")
    |> Entry.link("https://pedroassuncao.com/posts/#{id}")
    |> Entry.build()
  end
end
