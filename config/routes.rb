# frozen_string_literal: true

module Site
  class Routes < Hanami::Routes
    root to: "home"

    get "writing", to: "writing"
    get "writing/:slug", to: "article"
    get "feed.xml", to: "feed"

    get "speaking", to: "speaking"
    get "about", to: "about"
  end
end
