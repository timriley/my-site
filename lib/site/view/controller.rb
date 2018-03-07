# auto_register: false

require "builder"
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

      def call(context: nil, **input)
        # Always provide a new context object, so we don't carry over state
        # between renderings
        context ||= config.context.new

        super(context: context, **input)
      end
    end
  end
end
