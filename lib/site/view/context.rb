require "forwardable"
require "site/import"

module Site
  module View
    class Context
      extend Forwardable

      include Import["settings"]

      def_delegators :settings, :site_name, :site_author, :site_url
    end
  end
end
