defmodule NoozoWeb.TemplateUtils do
  @moduledoc """
  Generic utils for use in templates
  """
  alias NoozoWeb.VideoResolver

  def active(conn, paths) do
    active =
      Enum.reduce(paths, false, fn path, acc ->
        acc || String.starts_with?(conn.request_path, path)
      end)

    if active, do: "active", else: ""
  end

  # sobelow_skip ["XSS.Raw"]
  def abstract(html_content, max_size \\ 255) do
    html_content
    |> HtmlSanitizeEx.Scrubber.scrub(NoozoWeb.TextOnlyScrubber)
    |> Curtail.truncate(omission: "...", length: max_size)
    |> Phoenix.HTML.raw()
  end

  def post_content(post), do: post_content(post, truncate: nil)

  # sobelow_skip ["XSS.Raw"]
  def post_content(post, truncate: truncate) do
    content =
      case truncate do
        nil ->
          post.content

        length ->
          post.content
          |> Curtail.truncate(omission: post_read_more_link(post), length: length)
      end

    content
    |> VideoResolver.resolve_video_links()
    |> Phoenix.HTML.raw()
  end

  def format_date(date) do
    # date |> Timex.format!("{0D} {Mfull} {YYYY}")
    {:ok, relative_str} = date |> Timex.format("{relative}", :relative)
    relative_str
  end

  # sobelow_skip ["XSS.Raw"]
  def status_item(value, text, post) do
    val = if String.downcase(post.status) == String.downcase(value), do: "selected", else: ""
    "<option #{val} value=\"#{value}\">#{text}</option>" |> Phoenix.HTML.raw()
  end

  # Private

  defp post_read_more_link(post) do
    ~s(...<div class="read-more-link"><a href="/posts/#{post.id}">read more &gt;&gt;</a></div>)
  end
end
