require "fileutils"

module Site
  module Exporters
    class Files
      def call(root, path, contents)
        Dir.chdir(root) do
          sub_dir = File.dirname(path)
          FileUtils.mkdir_p(sub_dir) unless sub_dir == "."

          File.open(path, "w") do |file|
            file.write contents
          end
        end
      end
    end
  end
end
