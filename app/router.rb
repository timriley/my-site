require "hanami/router"

module Site
  class Router < Hanami::Router
    attr_reader :static_route_handlers

    def initialize(*)
      @static_route_handlers = []
      super
    end

    def get(path, to: nil, as: nil, **constraints, &blk)
      @static_route_handlers << [path, to]
      super
    end
  end
end
