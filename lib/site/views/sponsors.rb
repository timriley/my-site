require "site/import"
require "site/view/base"
require "site/view/parts/article"

module Site
  module Views
    class Sponsors < View::Base
      include Import["repos.article_repo"]

      config.template = "sponsors"
    end
  end
end
