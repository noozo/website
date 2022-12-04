defmodule Noozo.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Noozo.Accounts.User
  alias Noozo.Core.{MediumImportEntry, Page, Post, PostLike, Tag, Tagging}
  alias Noozo.Repo

  require Logger

  def list_posts do
    Post |> Repo.all()
  end

  def list_posts(params, published_only \\ true) do
    query =
      params[:tag_id]
      |> case do
        nil ->
          from(p in Post,
            # left_join: t in assoc(p, :taggings),
            left_join: pl in assoc(p, :post_likes),
            preload: [
              :tags,
              :post_likes
            ]
          )

        _ ->
          from(p in Post,
            left_join: t in assoc(p, :taggings),
            left_join: pl in assoc(p, :post_likes),
            where: t.tag_id == ^params[:tag_id],
            preload: [
              :tags,
              :post_likes
            ]
          )
      end

    query = if published_only, do: from(p in query, where: p.status == "published"), else: query

    query
    |> order_by(desc: :published_at)
    |> Repo.paginate(params)
  end

  def get_post!(id) do
    query =
      from(p in Post,
        left_join: pl in assoc(p, :post_likes),
        where: p.id == ^id,
        preload: [
          :tags,
          :post_likes
        ]
      )

    Repo.one!(query)
  end

  def get_post_by_slug!(slug) do
    slug
    |> post_by_slug_query()
    |> Repo.one!()
  end

  def get_post_by_slug(slug) do
    slug
    |> post_by_slug_query()
    |> Repo.one()
  end

  def last_post do
    query =
      from(
        p in Post,
        order_by: {:desc, :published_at},
        limit: 1
      )

    Repo.one!(query)
  end

  def create_post(attributes) do
    attributes =
      Map.merge(attributes, %{
        slug: slugify(attributes.title),
        status: attributes[:status] || "draft",
        published_at: attributes[:published_at] || Timex.now()
      })

    %Post{}
    |> Post.changeset(attributes)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs, before_save_func \\ & &1) do
    title = attrs[:title] || post.title

    attrs =
      attrs
      |> Map.merge(%{slug: slugify(title)})
      |> before_save(before_save_func)

    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  defp before_save(%{} = attrs, func) do
    func.(attrs)
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

  def user_liked_post?(ga_id, post) do
    query =
      from(
        l in PostLike,
        where: l.post_id == ^post.id and l.ga_id == ^ga_id
      )

    Repo.one(query) != nil
  end

  def like_post(ga_id, post_id) do
    post = Repo.one(from(p in Post, where: p.id == ^post_id))

    multi =
      Multi.new()
      |> Multi.insert(
        :post_like,
        PostLike.changeset(%PostLike{}, %{ga_id: ga_id, post_id: post.id})
      )
      |> Multi.update(:post, Post.changeset(post, %{like_count: post.like_count + 1}))

    case Repo.transaction(multi) do
      {:ok, %{post_like: _post_like, post: post}} ->
        {:ok, post |> Repo.preload(:post_likes)}

      {:error, :post_like, _failed_value, _changes_so_far} ->
        Logger.warn("User #{ga_id} already liked post #{post_id}")
        {:ok, post |> Repo.preload(:post_likes)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  def dislike_post(ga_id, post_id) do
    post = Repo.one(from(p in Post, where: p.id == ^post_id))

    multi =
      Multi.new()
      |> Multi.delete_all(
        :post_like,
        from(pl in PostLike, where: pl.ga_id == ^ga_id and pl.post_id == ^post.id)
      )
      |> Multi.update(:post, Post.changeset(post, %{like_count: post.like_count - 1}))

    case Repo.transaction(multi) do
      {:ok, %{post_like: _post_like, post: post}} ->
        {:ok, post |> Repo.preload(:post_likes)}

      {:error, :post_like, _failed_value, _changes_so_far} ->
        Logger.warn("User #{ga_id} already disliked post #{post_id}")
        {:ok, post |> Repo.preload(:post_likes)}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  ########### Pages

  def list_pages do
    Repo.all(Page)
  end

  def list_pages(params) do
    Repo.paginate(from(p in Page), params)
  end

  def get_page!(id) do
    Repo.get!(Page, id)
  end

  def get_page_by_slug(slug) do
    Repo.get_by(Page, slug: slug)
  end

  def create_page(attributes) do
    attributes =
      Map.merge(attributes, %{
        slug: slugify(attributes.title)
      })

    %Page{}
    |> Page.changeset(attributes)
    |> Repo.insert()
  end

  def update_page(%Page{} = page, attrs) do
    title = attrs.title || page.title

    attrs =
      Map.merge(attrs, %{
        slug: slugify(title)
      })

    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  def change_page(%Page{} = page) do
    Page.changeset(page, %{})
  end

  ########### Tags

  def list_tags do
    Repo.all(Tag)
  end

  def suggest_tags(name) do
    query =
      from(t in Tag,
        where: ilike(t.name, ^"%#{name}%")
      )

    Repo.all(query)
  end

  def list_taggings do
    Repo.all(Tagging)
  end

  def get_tag!(name) do
    Repo.get_by!(Tag, name: name)
  end

  def get_or_create_tag(name) do
    case Repo.get_by(Tag, name: name) do
      nil ->
        %Tag{}
        |> Tag.changeset(%{name: name})
        |> Repo.insert()

      tag ->
        {:ok, tag}
    end
  end

  def get_tagging!(tag_id, post_id) do
    query =
      from(t in Tagging,
        join: p in assoc(t, :post),
        where: t.tag_id == ^tag_id and p.id == ^post_id
      )

    Repo.all(query)
  end

  def delete_tagging!(tag_id, post_id) do
    tag_id
    |> get_tagging!(post_id)
    |> Enum.each(fn t -> Repo.delete(t) end)
  end

  def tag_post!(tag_name, post_id) do
    {:ok, tag} = get_or_create_tag(tag_name)

    %Tagging{}
    |> Tagging.changeset(%{tag_id: tag.id, taggable_type: "Post", taggable_id: post_id})
    |> Repo.insert()
  end

  ########### Users

  def get_user!(email) do
    {:ok, Repo.get_by!(User, email: email)}
  end

  ########### Medium

  def post_has_been_imported_from_medium?(medium_id) do
    Repo.get_by(MediumImportEntry, medium_id: medium_id) != nil
  end

  def mark_post_as_imported_from_medium(medium_id) do
    %MediumImportEntry{}
    |> MediumImportEntry.changeset(%{medium_id: medium_id})
    |> Repo.insert()
  end

  ########### Utils

  def slugify(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  def post_by_slug_query(slug) do
    from(p in Post,
      left_join: pl in assoc(p, :post_likes),
      where: p.slug == ^slug,
      preload: [
        :tags,
        :post_likes
      ]
    )
  end
end
