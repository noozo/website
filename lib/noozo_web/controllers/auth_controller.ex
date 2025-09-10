defmodule NoozoWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use NoozoWeb, :controller

  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  alias Noozo.Core

  def request(conn, %{"redirect_url" => redirect_url} = _params) do
    conn
    |> put_req_header("referer", redirect_url)
    |> put_session("redirect_url", redirect_url)
    |> render("request.html", callback_url: Helpers.callback_url(conn))
  end

  def request(conn, params), do: request(conn, Map.put(params, "redirect_url", "/admin"))

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate with Google.")
    |> redirect(to: "/auth/identity?#{URI.encode_query(%{redirect_url: "/admin"})}")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    redirect_url = get_session(conn, "redirect_url") || params["redirect_url"] || "/admin"

    case google_login(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated with Google.")
        |> put_session("current_user", user)
        |> configure_session(renew: true)
        |> redirect(to: redirect_url)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/auth/identity?#{URI.encode_query(%{redirect_url: redirect_url})}")
    end
  end

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
        %{"redirect_url" => redirect_url, "code" => two_factor_code} = _params
      ) do
    case login(auth, two_factor_code) do
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

  defp login(auth, two_factor_code) do
    {:ok, user} = Core.get_user!(auth.info.email)

    if Bcrypt.verify_pass(auth.credentials.other.password, user.encrypted_password) do
      check_2fa_auth(user, two_factor_code)
    else
      {:error, "Could not authenticate user"}
    end
  end

  defp google_login(auth) do
    {:ok, user} = Core.get_user!(auth.info.email)

    # For Google auth, bypass password and 2FA for admin users
    # Allow emails configured via environment variable or default admin email
    authorized_emails =
      System.get_env("AUTHORIZED_GOOGLE_EMAILS", "assuncas@gmail.com")
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    if user.email in authorized_emails do
      {:ok, user}
    else
      {:error, "Google login not authorized for this email address"}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, "User not found"}
  end

  defp check_2fa_auth(%{has_2fa: false} = user, _code), do: {:ok, user}

  defp check_2fa_auth(user, code) do
    # In development, bypass 2FA validation
    if Mix.env() == :dev do
      {:ok, user}
    else
      # In production, validate 2FA normally
      if NimbleTOTP.valid?(user.secret_2fa, code) do
        {:ok, user}
      else
        {:error, "Invalid 2FA code"}
      end
    end
  end
end
