defmodule Noozo.ReleaseTasks do
  @moduledoc """
  Release tasks
  """
  alias Ecto.Migrator

  alias Noozo.Core
  alias Noozo.Cvs
  alias Noozo.Cvs.CvSectionItem
  alias Noozo.Gallery
  alias Noozo.Gallery.Image
  alias Noozo.Images
  alias Noozo.Repo

  def migrate do
    {:ok, _} = Application.ensure_all_started(:noozo)

    path = Application.app_dir(:noozo, "priv/repo/migrations")

    Migrator.run(Repo, path, :up, all: true)
  end

  def regen_images do
    for post <- Core.list_posts() do
      Images.create(Core.Post.image_data_for_disk(post))
    end

    for item <- Cvs.list_section_items() do
      Images.create(CvSectionItem.image_data_for_disk(item))
    end

    for gallery_image <- Gallery.list() do
      Images.create(Image.image_data_for_disk(gallery_image))
    end

    for cv_image <- Cvs.list_cvs() do
      Images.create(Image.image_data_for_disk(cv_image))
    end
  end
end
