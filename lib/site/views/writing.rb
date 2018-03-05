require "site/import"
require "site/view/controller"
require "site/view/parts/article"

module Site
  module Views
    class Writing < View::Controller
      include Site::Import["repos.article_repo"]

      configure do |config|
        config.template = "writing"
      end

      expose :articles, as: View::Parts::Article do
        article_repo.published
      end
    end
  end
end
