# frozen_string_literal: true

require "hanami"

module Site
  class App < Hanami::App
    # Allow my external reference to highlight.js (see app layout)
    config.actions.content_security_policy[:script_src] += " 'unsafe-inline' https://cdnjs.cloudflare.com/"

    # Loads the database from the content files in source/ whenever the app is prepared.
    #
    # This allows the app to be fully navigated while acting as a live Hanami web app.
    #
    # FIXME: This means we load the database even for auxiliary actions, like invoking the CLI and
    # running the assets compiler/watcher. Find a way to limit this to the main app process only.
    def self.prepare
      super
      self["prepare"].call(config.root)
    end

    def self.build
      self["build"].(config.root)
    end
  end
end
