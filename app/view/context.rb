require "dry/core/constants"
require "forwardable"
require "hanami/view/context"
require "uri"

module Site
  module View
    class Context < Hanami::View::Context
      extend Forwardable

      include Dry::Core::Constants

      include Deps["assets", "settings"]

      def_delegators :settings, :site_title, :site_author, :site_url

      attr_reader :current_path

      def initialize(current_path: nil, **args)
        @current_path = current_path
        super(**args)
      end

      def with(current_path:)
        self.class.new(current_path: current_path)
      end

      def page_title(new_title = Undefined)
        if new_title == Undefined
          [@page_title, site_title]
            .reject { |str| str.to_s.empty? }
            .join(" | ")
        else
          @page_title = new_title
        end
      end

      def asset_path(path)
        if URI(path).absolute?
          path
        else
          assets[path]
        end
      end
    end
  end
end
