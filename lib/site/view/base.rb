# auto_register: false

require "builder"
require "hanami/view"
require "slim"

module Site
  module View
    class Base < Hanami::View
      config.paths = [Hanami.application.root.join("templates")]
      config.default_context = Hanami.application["view.context"]
      config.layout = "site"

      def call(context: nil, **input)
        # Always provide a new context object, so we don't carry over state
        # between renderings
        context ||= config.default_context.with({})

        super(context: context, **input)
      end
    end
  end
end
