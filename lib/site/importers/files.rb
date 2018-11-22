require "front_matter_parser"
require "pathname"
require "transproc"
require "yaml"

require "site/import"

module Site
  module Importers
    class Files
      module Functions
        extend Transproc::Registry
        import :deep_symbolize_keys, from: Transproc::HashTransformations, as: :symbolize
      end

      FRONT_MATTER_LOADER = -> str {
        YAML.safe_load(str, _whitelist_classes = [Date, Time])
      }.freeze

      include Import[
        "database.rom",
        "inflector",
      ]

      def call(dir, pattern = "**/*")
        records = Dir[File.join(dir, pattern)]
          .select(&File.method(:file?))
          .map { |file_name| parse_data(file_name, dir: dir) }

        records.each do |record|
          type = record.delete(:type)
          rom.relations.fetch(inflector[type, :pluralize]).insert(record)
        end

        records
      end

      private

      def parse_data(file_name, dir:)
        relative_file_path = Pathname(file_name).relative_path_from(Pathname(dir)).to_s

        parsed_file = FrontMatterParser::Parser.parse_file(file_name, loader: FRONT_MATTER_LOADER)
        data = Functions[:symbolize][parsed_file.front_matter]
        type = data[:type] || infer_type_from_file_name(relative_file_path)

        data.merge(
          type: type,
          path: relative_file_path,
          body: parsed_file.content,
        )
      end

      FILE_WITH_TYPE_REGEXP = %r{^(?<name>[^\.]+)\.(?<type>[^\.]+)\.(?<exts>.+)$}

      def infer_type_from_file_name(file_name)
        if (match = FILE_WITH_TYPE_REGEXP.match(file_name))
          match[:type]
        end
      end
    end
  end
end
