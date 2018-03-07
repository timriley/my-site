# auto_register: false

require "dry/view/controller"
require "slim"
require "site/container"

module Site
  module View
    class Controller < Dry::View::Controller
      configure do |config|
        config.paths = [Container.root.join("templates")]
        config.context = Container["view.context"]
        config.layout = "site"
      end
    end
  end
end
