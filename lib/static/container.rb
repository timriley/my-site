# auto_register: false

require "dry/system/container"
require "dry/system/components"

module Static
  class Container < Dry::System::Container
    use :env

    load_paths! "lib"

    configure do |config|
      config.root = Pathname(__dir__).join("../..").realpath
      config.name = :static
      config.default_namespace = "static"
      config.auto_register = %w[lib/static]
    end
  end
end
