require "site/view/base"

module Site
  module Views
    class About < View::Base
      configure do |config|
        config.template = "about"
      end
    end
  end
end
