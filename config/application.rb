# frozen_string_literal: true

require "hanami"
require "break"

module Site
  class Application < Hanami::Application
    def self.build
      self["build"].(config.root)
    end
  end
end


# This is here to allow the router to work without a `slice do` block
#
# FIXME: update the router to support this

require "hanami/application/routing/resolver"

module Hanami
  class Application
    module Routing
      class Resolver
        def resolve_string_identifier(path, identifier)
          # slice_name = slices_registry.find(path) or raise "missing slice for #{path.inspect} (#{identifier.inspect})"
          # slice = slices[slice_name]

          slice_name = slices_registry.find(path)
          slice = slice_name ? slices[slice_name] : Hanami.application

          action_key = "actions.#{identifier.gsub(/[#\/]/, '.')}"

          slice[action_key]
        end
      end
    end
  end
end
