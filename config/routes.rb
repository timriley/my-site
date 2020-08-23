# frozen_string_literal: true

Hanami.application.routes do
  root to: "home"

  get "writing", to: "writing"
  get "writing/:slug", to: "article"
  get "feed.xml", to: "feed"

  get "speaking", to: "speaking"
  get "about", to: "about"
end
