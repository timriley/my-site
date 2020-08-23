require "site/view/base"
require "site/view/parts/article"

module Site
  module Views
    class Article < View::Base
      include Deps["repos.article_repo"]

      expose :article, as: View::Parts::Article do |slug:|
        article_repo.get_by_slug(slug)
      end
    end
  end
end
