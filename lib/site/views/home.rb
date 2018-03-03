require "site/view/controller"

module Site
  module Views
    class Home < View::Controller
      configure do |config|
        config.template = "home"
      end
    end
  end
end
