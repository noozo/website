defmodule Noozo.Accounts.User do
  @moduledoc """
  A website user
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:email]}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :reset_password_token, :string
    field :reset_password_sent_at, :utc_datetime
    field :remember_created_at, :utc_datetime
    field(:has_2fa, :boolean, default: false)
    field(:secret_2fa, :binary)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :encrypted_password, :has_2fa, :secret_2fa])
    |> validate_required([:email, :encrypted_password])
  end
end
