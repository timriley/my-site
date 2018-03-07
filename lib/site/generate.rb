require "fileutils"
require "site/import"
require "dry/monads"
require "dry/monads/result"

module Site
  class Generate
    include Dry::Monads::Result::Mixin

    include Import[
      "settings",
      export: "exporters.files",
      home_view: "views.home",
      writing_view: "views.writing",
      feed_view: "views.feed",
    ]

    def call(root)
      export_dir = File.join(root, settings.export_dir)

      FileUtils.rm_rf(export_dir, secure: true)
      FileUtils.mkdir_p(export_dir)

      export.(export_dir, "index.html", home_view.())
      export.(export_dir, "writing/index.html", writing_view.())
      export.(export_dir, "feed.xml", feed_view.())

      Success(:ok)
    end
  end
end
