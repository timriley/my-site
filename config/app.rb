# frozen_string_literal: true

require "hanami"

module Site
  class App < Hanami::App
    # Loads the database from the content files in source/ whenever the app is prepared.
    #
    # This allows the app to be fully navigated while acting as a live Hanami web app.
    def self.prepare
      super
      self["prepare"].call(config.root)
    end

    def self.build
      self["build"].(config.root)
    end
  end
end
