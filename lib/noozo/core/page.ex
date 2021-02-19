defmodule Noozo.Core.Page do
  @moduledoc """
  A page
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :title, :string
    field :content, :string
    field :slug, :string

    # belongs_to :user, Noozo.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs \\ %{}) do
    page
    |> cast(attrs, [:title, :content, :slug])
    |> validate_required([:title, :content, :slug])
  end
end
