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

alias Noozo.Accounts
alias Noozo.Todo

Todo.create_label(%{title: "video", color_hex: "#42CAFD"})
Todo.create_label(%{title: "website", color_hex: "#CCFCCB"})
Todo.create_label(%{title: "metalwork", color_hex: "#313638"})
Todo.create_label(%{title: "woodworking", color_hex: "#F5853F"})
Todo.create_label(%{title: "important", color_hex: "#F22B29"})

unless Accounts.get_user(1) do
  # Default pass is admin, be sure to change it
  Noozo.Accounts.create_user(%{
    email: "admin@admin",
    encrypted_password: "$2b$12$XszdnjL98t5ecZ7meJdT2OqUrqF6QKKFgQi6n25wwQ4PehORZxqby"
  })
end
