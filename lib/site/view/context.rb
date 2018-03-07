require "dry/core/constants"
require "forwardable"
require "site/import"

module Site
  module View
    class Context
      extend Forwardable

      include Dry::Core::Constants

      include Import["settings"]

      def_delegators :settings, :site_name, :site_author, :site_url

      def initialize(*)
        super
        @page_title = nil
      end

      def page_title(new_title = Undefined)
        if new_title == Undefined
          [@page_title, site_name].compact.join(" | ")
        else
          @page_title = new_title
        end
      end

      def new
        self.class.new
      end
    end
  end
end
