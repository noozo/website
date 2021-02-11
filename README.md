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
- Other things
  - Live pagination across the board (i.e. no full page updates)
  - LiveUploads for most file upload operations (like post images, for instance)
  - Credo for code guidelines
  - Sobelow for security advising
  - No tests, living on the edge :)
  - Github actions script to deploy the website to a remote machine (for instance Linode)
  - LiveDashboard to visualize website metrics and performance

## Your mileage may vary

Apart from the obvious:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`
- Now you can visit [`localhost:4001`](https://localhost:4001) from your browser.

You might also want to:

- Replace ocurrences of `pedroassuncao.com` with your own domain throughout the code
- Take a look at all the configs to see if they match your needs
- Change .github/main.yml and adjust the deployment as you need (first time you run it you will need to add dependencies on your target machine and other things like that)

## Finally

As with most projects the code is far from perfect so, if you like this project and end up using it, consider helping me improve it by sending pull requests.

I would really appreciate it.

Happy coding!
