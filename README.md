# pedroassuncao.com

## A blog and much, much more.

This is my personal website repository. I decided to make it open source because someone else might benefit from the work i have done over the years even though, at times, some functionality might not have the perfect implementation, so take it as it is if you want :)

Most features have an equivalent admin space where things can be configured.

## What does it do?

- Self contained website
  - No reverse proxy in front, like nginx
  - HTTPS directly from Phoenix using Saša Jurić's outstanding site_encrypt library for certificate auto-updates: https://github.com/sasa1977/site_encrypt
- A blog infrastructure
  - Support for multi users (though admin is not there)
  - Tagged posts
  - Post creation with preview, title suggestions, and a poster image per post (using LiveUploads)
  - Slug urls
  - Example: https://pedroassuncao.com/posts
- Dynamic pages
  - Similar to blog posts, except with no tags (useful for semi-static information)
  - Example: https://pedroassuncao.com/pages/uses
- CV/Resume hosting
  - Backoffice for resume management (LiveView with realtime preview)
  - Multi user support (at the DB level)
  - Example: https://pedroassuncao.com/resume/1
- Daily log management
  - A one page per day journal i build to keep track of tasks at work (and be able to say what i did the day before :))
  - Live preview as you type in markdown
- A Trello clone for keeping track of tasks
  - Board management
  - Add/remove/move/hide lists
  - Add/change/move/delete list items
  - Drag and drop
  - List item labels
- Server side analytics
  - Keeps track of page visits asynchronously (thanks to Jose Valim for sharing his implementation: https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir)
  - Backoffice visualization with interval charts using chartist.js
- Image gallery
  - Backoffice to upload images
  - Image ordering
  - Frontend with Lightbox image zooming
  - Images stored in DB (i know) with file caching on top
- Finances visualizer
  - In the off-chance you are Portuguese and have an account at Caixa Geral de Depositos, there is an admin section where you can import CSV bank movements (exported from the bank's website) and then visualize them in a more convenient fashion. That particular live view should be easy to adapt to any type of CSV file, so you can use it with any bank
- A GenServer that can import posts from medium
  - In case you also write on medium.com, there is a (disabled in application.ex) GenServer that can periodically fetch posts from there and add them into the blog
- Other things
  - Live pagination across the board (i.e. no full page updates)
  - LiveUploads for most file upload operations (like post images, for instance)
  - Credo for code guidelines
  - Sobelow for security advising
  - No tests, living on the edge :)
  - Github actions script to deploy the website to a remote machine (for instance Linode)
  - LiveDashboard to visualize website metrics and performance
  - TailwindCSS for cosmetics
  - AlpineJS for some sprinkles of JS
  - LiveView hooks for things like drag and drop and charts

## Your mileage may vary

Apart from the obvious:

- Copy `.env_example` to `.env` and adjust as needed
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Run seeds to create default admin@admin/admin user with `mix run priv/repo/seeds.exs`
  - Be sure to change the password and email later on. You can do that by replacing encrypted_password with the result of `Bcrypt.hash_pwd_salt("<YOUR_NEW_PASSWORD>")`.
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`
- Now you can visit [`localhost:4001`](https://localhost:4001) from your browser.

You might also want to:

- Replace ocurrences of `pedroassuncao.com` with your own domain throughout the code
- Take a look at all the configs to see if they match your needs
- Change .github/main.yml and adjust the deployment as you need (first time you run it you will need to add dependencies on your target machine and other things like that)
- Search for my github content hardcoded avatar in a few places and replace with yours :)

## Notes

To run port 80 and 443 in a remote machine you might need to provide permissions to your BEAM binary, for instance (for elixir 1.11, and inside the target folder):

```
sudo setcap CAP_NET_BIND_SERVICE=+eip _build/prod/rel/noozo/erts-11.1/bin/beam.smp
```

## Finally

As with most projects the code is far from perfect so, if you like this project and end up using it, consider helping me improve it by sending pull requests.

I would really appreciate it.

Happy coding!
