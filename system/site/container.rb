require "pathname"
require "dry/system/container"
require "dry/system/components"

module Site
  class Container < Dry::System::Container
    use :env

    load_paths! "lib"

    configure do |config|
      config.root = Pathname(__dir__).join("../..").realpath
      config.name = :site
      config.default_namespace = "site"
      config.auto_register = %w[lib/site]
    end

    def self.build
      self["build"].(config.root)
    end
  end
end
