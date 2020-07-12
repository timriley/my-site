require "site/import"
require "site/view/base"
require "site/view/parts/article"

module Site
  module Views
    class Home < View::Base
      include Import["repos.article_repo"]

      configure do |config|
        config.template = "home"
      end

      expose :articles, as: View::Parts::Article do
        article_repo.published(limit: 5)
      end
    end
  end
end
