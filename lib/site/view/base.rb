# auto_register: false

require "builder"
require "hanami/view"
require "slim"
require "site/container"

module Site
  module View
    class Base < Hanami::View
      configure do |config|
        config.paths = [Container.root.join("templates")]
        config.default_context = Container["view.context"]
        config.layout = "site"
      end

      def call(context: nil, **input)
        # Always provide a new context object, so we don't carry over state
        # between renderings
        context ||= config.default_context.with({})

        super(context: context, **input)
      end
    end
  end
end
