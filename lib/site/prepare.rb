require "pathname"
require "dry/monads"
require "dry/monads/result"

module Site
  class Prepare
    include Dry::Monads::Result::Mixin

    include Import[
      "settings",
      import_files: "importers.files"
    ]

    def call(root)
      import_files.(File.join(root, settings.import_dir))
      Success()
    end
  end
end
