require "site/view/controller"
require "site/view/parts/article"

module Site
  module Views
    class Article < View::Controller
      configure do |config|
        config.template = "article"
      end

      expose :article, as: View::Parts::Article
    end
  end
end
