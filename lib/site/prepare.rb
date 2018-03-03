require "pathname"
require "dry/monads"
require "dry/monads/result"
require "site/import"

module Site
  class Prepare
    include Dry::Monads::Result::Mixin

    include Import[
      "settings",
      import_files: "importers.files"
    ]

    def call(root)
      import_files.(File.join(root, settings.import_dir))
      Success(:ok)
    end
  end
end
