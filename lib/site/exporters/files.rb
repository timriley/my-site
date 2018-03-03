module Site
  module Exporters
    class Files
      def call(root, path, contents)
        File.open(File.join(root, path), "w") do |file|
          file.write contents
        end
      end
    end
  end
end
