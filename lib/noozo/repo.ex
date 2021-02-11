defmodule Noozo.Repo do
  use Ecto.Repo,
    otp_app: :noozo,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  @spec errors_from_changeset(Ecto.Changeset.t()) :: String.t()
  def errors_from_changeset(changeset) when is_map(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {msg, _}} ->
      "#{field}: #{msg}"
    end)
    |> Enum.join(", ")
  end
end

defmodule Noozo.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      # @derive {Phoenix.Param, key: :uuid}
    end
  end
end
