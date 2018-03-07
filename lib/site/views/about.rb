require "site/view/controller"

module Site
  module Views
    class About < View::Controller
      configure do |config|
        config.template = "about"
      end
    end
  end
end
