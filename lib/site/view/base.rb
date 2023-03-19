# auto_register: false

require "builder"
require "hanami/view"
require "slim"

module Site
  module View
    class Base < Hanami::View
      configure do |config|
        config.paths = [Container.root.join("templates")]
        config.default_context = Container["view.context"]
        config.layout = "site"
      end
    end
  end
end

# Temporary patch for Tilt to work around issues with the .builder template type and how hanami-view
# passes a `{locals: locals}` locals hash when rendering templates
module Tilt
  class Template
    def local_extraction(local_keys)
      # New code: put locals last so that assigning it doesn't blow away subsequent locals
      if local_keys.include?(:locals)
        local_keys.delete(:locals)
        local_keys.append(:locals)
      end

      # Original code
      local_keys.map do |k|
        if k.to_s =~ /\A[a-z_][a-zA-Z_0-9]*\z/
          "#{k} = locals[#{k.inspect}]"
        else
          raise "invalid locals key: #{k.inspect} (keys must be variable names)"
        end
      end.join("\n")
    end
  end
end
