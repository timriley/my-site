# auto_register: false

require "yaml"
require "open-uri"

module Site
  module Assets
    ASSETS_DIR = "assets".freeze

    class Precompiled
      attr_reader :root

      def initialize(root)
        @root = root
      end

      def [](asset)
        if (path = manifest[asset])
          "/#{ASSETS_DIR}/#{path}"
        end
      end

      def read(asset)
        path = self[asset]

        if File.exist?("#{root}#{path}")
          File.read("#{root}#{path}")
        end
      end

      private

      def manifest
        @manifest ||= YAML.load_file(manifest_path)
      end

      def manifest_path
        "#{root}/#{ASSETS_DIR}/manifest.json"
      end
    end

    class Served
      attr_reader :url

      def initialize(url:)
        @url = url
      end

      def [](asset)
        "#{url}/#{ASSETS_DIR}/#{asset}"
      end

      def read(asset)
        path = self[asset]
        open(path, "r:UTF-8").read
      end
    end
  end
end
