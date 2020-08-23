require "fileutils"
require "dry/monads"
require "dry/monads/result"
require "mustermann"
require "uri"
require_relative "router"

module Site
  class Generate
    include Dry::Monads::Result::Mixin

    include Deps[
      "settings",
      export: "exporters.files",
    ]

    def call(root)
      export_dir = File.join(root, settings.export_dir)

      FileUtils.mkdir_p(File.join(export_dir, "assets", "content"))
      FileUtils.cp_r File.join(root, "assets", "content"), File.join(export_dir, "assets", "content")

      static_router = Router.new(&Hanami.application.routes)

      static_router.static_route_handlers.each do |(path, identifier)|
        # TODO: use actual app endpoint resolver
        action = Hanami.application["actions.#{identifier}"]

        route = Mustermann.new(path)

        if route.names.any?
          action.each do |params|
            # TODO: having to unescape here is a bit gross
            file_path = URI.unescape(route.expand(:raise, params)) + "/index.html"

            response = action.call(params)

            contents = response.body.to_a.join

            export.(export_dir, file_path, contents)
          end
        else
          response = action.call({})

          # TODO: make nicer
          file_path =
            if path == "/"
              "index.html"
            elsif path =~ /\.xml$/ # TODO make generic
              path
            else
              "#{path}/index.html"
            end

          contents = response.body.to_a.join

          export.(export_dir, file_path, contents)
        end
      end

      Success()
    end
  end
end
