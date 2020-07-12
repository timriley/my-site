require "site/import"
require "site/view/base"
require "site/view/parts/article"

module Site
  module Views
    class Feed < View::Base
      include Site::Import["settings", "repos.article_repo"]

      configure do |config|
        config.template = "feed"
        config.default_format = "xml"
        config.layout = false
      end

      expose :articles, as: View::Parts::Article do
        article_repo.published
      end

      expose :settings do
        settings
      end
    end
  end
end
