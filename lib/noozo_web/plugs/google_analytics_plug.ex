defmodule NoozoWeb.GoogleAnalyticsPlug do
  @moduledoc """
  GA plug
  """
  import Plug.Conn
  use NoozoWeb, :controller

  def init(opts) do
    opts
  end

  case Mix.env() do
    :prod ->
      def call(conn, _opts),
        do: put_session(conn, "ga_id", conn.req_cookies["_ga"] || conn.req_cookies[:_ga])

    _ ->
      def call(conn, _opts), do: put_session(conn, "ga_id", "test_ga_id")
  end
end
