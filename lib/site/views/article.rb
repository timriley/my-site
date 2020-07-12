require "site/view/base"
require "site/view/parts/article"

module Site
  module Views
    class Article < View::Base
      configure do |config|
        config.template = "article"
      end

      expose :article, as: View::Parts::Article
    end
  end
end
