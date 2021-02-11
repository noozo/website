defmodule Noozo.Repo.Migrations.CreateCVStructure do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:cvs, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false

      timestamps()
    end

    create_if_not_exists index("cvs", [:user_id])

    create_if_not_exists table(:cv_header_items, primary_key: false) do
      add :uuid, :uuid, primary_key: true

      add :cv_uuid, references(:cvs, on_delete: :delete_all, type: :uuid, column: :uuid),
        null: false

      add :content, :text, null: false

      timestamps()
    end

    create_if_not_exists index("cv_header_items", [:cv_uuid])

    create_if_not_exists table(:cv_sections, primary_key: false) do
      add :uuid, :uuid, primary_key: true

      add :cv_uuid, references(:cvs, on_delete: :delete_all, type: :uuid, column: :uuid),
        null: false

      add :title, :string, null: false

      timestamps()
    end

    create_if_not_exists index("cv_sections", [:cv_uuid])

    create_if_not_exists table(:cv_section_items, primary_key: false) do
      add :uuid, :uuid, primary_key: true

      add :cv_section_uuid,
          references(:cv_sections, on_delete: :delete_all, type: :uuid, column: :uuid),
          null: false

      add :image, :bytea
      add :image_type, :string
      add :date_from, :date
      add :date_to, :date
      add :title, :string
      add :subtitle, :string
      add :content, :text, null: false
      add :footer, :string

      timestamps()
    end

    create_if_not_exists index("cv_section_items", [:cv_section_uuid])
  end
end
