defmodule NoozoWeb.Admin.Accounts.TwoFactorSetupView do
  @moduledoc """
  Setup 2 FA for a user
  """
  use Phoenix.LiveView

  alias Noozo.Accounts

  @env Mix.env()

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    secret = NimbleTOTP.secret()
    uri = NimbleTOTP.otpauth_uri("pedroassuncao.com:#{@env}", secret, issuer: "pedroassuncao.com")
    svg = uri |> EQRCode.encode() |> EQRCode.svg()

    {:noreply, assign(socket, user: Accounts.get_user!(id), secret: secret, svg: svg)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= if !@user.has_2fa or is_nil(@user.secret_2fa) do %>
      <div>Read the code into your authenticator app</div>
      <div class="w-4 h-4 float-right"><%= Phoenix.HTML.raw(@svg) %></div>
      <form phx-submit="save_secret">
        <div class="grid grid-cols-6 gap-4">
          <div class="col-span-6">
            <label for="code">Code</label>
            <input type="text" name="code" />
          </div>
          <div class="col-span-6">
            <input class="btn" type="submit" value="Setup 2FA" />
          </div>
        </div>
      </form>
    <% else %>
      User has 2FA all set up. TODO: Reset.
    <% end %>
    """
  end

  @impl true
  def handle_event("save_secret", %{"code" => code} = _event, socket) do
    secret = socket.assigns.secret

    if NimbleTOTP.valid?(secret, code) do
      {:ok, user} =
        Accounts.update_user(socket.assigns.user, %{
          has_2fa: true,
          secret_2fa: secret
        })

      {:noreply, socket |> put_flash(:info, "2FA setup correctly") |> assign(:user, user)}
    else
      {:noreply, socket |> put_flash(:error, "Invalid code")}
    end
  end
end
