defmodule NoozoWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use NoozoWeb, :controller
  alias Noozo.Core
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, %{"redirect_url" => redirect_url} = params) do
    conn
    |> put_req_header("referer", redirect_url)
    |> render("request.html", callback_url: Helpers.callback_url(conn))
  end

  def request(conn, params), do: request(conn, Map.put(params, "redirect_url", "/admin"))

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  # def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
  #   conn
  #   |> put_flash(:error, "Failed to authenticate.")
  #   |> redirect(to: "/")
  # end

  def identity_callback(
        %{assigns: %{ueberauth_auth: auth}} = conn,
        %{"redirect_url" => redirect_url} = _params
      ) do
    case login(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session("current_user", user)
        |> configure_session(renew: true)
        |> redirect(to: redirect_url)

      {:error, reason} ->
        conn
        |> put_req_header("referer", redirect_url)
        |> put_flash(:error, reason)
        |> assign(:email, auth.info.email)
        |> render("request.html", callback_url: Helpers.callback_url(conn))
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out.")
    |> put_session("current_user", nil)
    |> assign(:current_user, nil)
    |> redirect(to: "/")
  end

  defp login(auth) do
    {:ok, user} = Core.get_user!(auth.info.email)

    if Bcrypt.verify_pass(auth.credentials.other.password, user.encrypted_password) do
      {:ok, user}
    else
      {:error, "Could not authenticate user"}
    end
  end
end
