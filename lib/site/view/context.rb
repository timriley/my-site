require "dry/core/constants"
require "forwardable"
require "hanami/view/context"
require "site/import"
require "uri"

module Site
  module View
    class Context < Hanami::View::Context
      extend Forwardable

      include Dry::Core::Constants

      include Import["assets", "settings"]

      def_delegators :settings, :site_title, :site_author, :site_url

      attr_reader :current_path

      def initialize(current_path: nil, **deps)
        super(**deps)

        @deps = deps
        @current_path = current_path
        @page_title = nil
      end

      def page_title(new_title = Undefined)
        if new_title == Undefined
          [@page_title, settings.site_title].compact.join(" | ")
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
