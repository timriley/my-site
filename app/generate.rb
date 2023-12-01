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

      # Copy assets into place
      FileUtils.cp_r(root.join("public", "assets"), File.join(export_dir, "assets"))
      FileUtils.cp(root.join("public", "assets.json"), export_dir)

      static_router = Router.new(&Hanami.app.routes)

      static_router.static_route_handlers.each do |(path, identifier)|
        # TODO: use actual app endpoint resolver
        action = Hanami.app["actions.#{identifier}"]

        route = Mustermann.new(path)

        if route.names.any?
          action.each do |params|
            # TODO: having to unescape here is a bit gross
            # LATER TODO: why? something to do with slashes? Figure out what feels clean.
            file_path = URI::DEFAULT_PARSER.unescape(route.expand(:raise, params)) + "/index.html"

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
