# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Noozo.Repo.insert!(%Noozo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# Enum.each(10..20, fn i ->
#   {:ok, _post} =
#     Noozo.Core.create_post(%{
#       title: "Test post #{i}",
#       content: "<div>This is the content</div>",
#       published_at: DateTime.utc_now(),
#       slug: "test-post"
#     })
# end)

Noozo.Todo.create_label(%{title: "video", color_hex: "#42CAFD"})
Noozo.Todo.create_label(%{title: "website", color_hex: "#CCFCCB"})
Noozo.Todo.create_label(%{title: "metalwork", color_hex: "#313638"})
Noozo.Todo.create_label(%{title: "woodworking", color_hex: "#F5853F"})
Noozo.Todo.create_label(%{title: "important", color_hex: "#F22B29"})
