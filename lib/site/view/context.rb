require "dry/core/constants"
require "forwardable"
require "site/import"

module Site
  module View
    class Context
      extend Forwardable

      include Dry::Core::Constants

      include Import["assets", "settings"]

      def_delegators :settings, :site_name, :site_author, :site_url

      attr_reader :current_path

      def initialize(current_path: nil, **deps)
        super(**deps)

        @deps = deps
        @current_path = current_path
        @page_title = nil
      end

      def page_title(new_title = Undefined)
        if new_title == Undefined
          [@page_title, site_name].compact.join(" | ")
        else
          @page_title = new_title
        end
      end

      def new(**new_options)
        self.class.new(@deps.merge(current_path: current_path).merge(new_options))
      end
    end
  end
end
