# frozen_string_literal: true

require "hanami"

module Site
  class App < Hanami::App
    def self.build
      self["build"].(config.root)
    end
  end
end
