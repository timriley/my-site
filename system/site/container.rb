require "pathname"
require "dry/system"
require "dry/system/container"
require "dry/system/provider_sources"

module Site
  class Container < Dry::System::Container
    use :env

    add_to_load_path! "lib"

    configure do |config|
      config.name = :site
      config.root = Pathname(__dir__).join("../..").realpath
      config.component_dirs.add "lib/site" do |dir|
        dir.namespaces.add_root const: "site"
      end
    end

    def self.build
      self["build"].(config.root)
    end
  end

  Import = Container.injector
end
