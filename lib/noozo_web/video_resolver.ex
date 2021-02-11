defmodule NoozoWeb.VideoResolver do
  @moduledoc """
    Utilities to convert [youtube=<some_id>] into the proper HTML to render a video on a web page
  """
  # Can't be private because i'm dynamically calling them
  def youtube_embed(video_id) do
    """
    <div class=\"video embed-responsive embed-responsive-16by9\">
      <iframe class=\"embed-responsive-item\" frameborder=\"0\" height=\"315\" src=\"https://www.youtube.com/embed/#{
      video_id
    }\" width=\"560\"></iframe>
      <br/>
      Subscribe to my channel on <script src=\"https://apis.google.com/js/platform.js\"></script>
      <div class=\"g-ytsubscribe\" data-channelid=\"UCBE9Gud_bb-xrwHFAmKpxug\" data-layout=\"default\" data-count=\"default\"></div>
    </div>
    """
  end

  def vimeo_embed(video_id) do
    """
    <div class=\"video embed-responsive embed-responsive-16by9\">
      <iframe class=\"embed-responsive-item\" src=\"https://player.vimeo.com/video/#{video_id}\" width=\"640\" height=\"360\"
    frameborder=\"0\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
    </div>
    """
  end

  def resolve_video_links(content) do
    case Regex.scan(~r/\[(youtube|vimeo)=(.*)\]/, content) do
      # Nothing to do, no links found
      [] ->
        content

      # Resolve links into proper html
      # matches -> Regex.scan(~r/\[(youtube|vimeo)=(.*)\]/, content)
      matches ->
        matches
        |> Enum.map(&resolve_video_link/1)
        |> Enum.reduce(content, fn resolved_match, content ->
          {to_replace, resolved_html} = resolved_match
          String.replace(content, to_replace, resolved_html)
        end)
    end
  end

  # sobelow_skip ["DOS.StringToAtom"]
  defp resolve_video_link(match) do
    [match, type, video_id] = match
    {match, apply(__MODULE__, String.to_atom("#{type}_embed"), [video_id])}
  end
end
