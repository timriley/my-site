require "front_matter_parser"
require "pathname"
require "transproc"
require "yaml"

require "static/import"

module Static
  module Loaders
    class Files
      module Functions
        extend Transproc::Registry
        import :deep_symbolize_keys, from: Transproc::HashTransformations, as: :symbolize
      end

      FRONT_MATTER_LOADER = -> str {
        YAML.safe_load(str, _whitelist_classes = [Date, Time])
      }.freeze

      include Import["database.rom"]

      def call(dir, pattern = "**/*")
        records = Dir[File.join(dir, pattern)]
          .select(&File.method(:file?))
          .map { |file| parse_data(file, dir: dir) }

        records.each do |record|
          # Hard code `:articles` right now
          # Next, we'll infer this from an attribute or a file extension
          rom.relations[:articles].insert(record)
        end

        records
      end

      private

      def parse_data(file, dir:)
        parsed_file = FrontMatterParser::Parser.parse_file(file, loader: FRONT_MATTER_LOADER)

        Functions[:symbolize][parsed_file.front_matter].merge(
          path: Pathname(file).relative_path_from(dir).to_s,
          body: parsed_file.content,
        )
      end
    end
  end
end
