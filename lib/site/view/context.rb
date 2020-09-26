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

      def initialize(page_title: "", **deps)
        super
      end

      def current_path
        _options[:current_path]
      end

      def page_title(new_title = Undefined)
        if new_title == Undefined
          [_options[:page_title], site_title]
            .reject { |str| str.to_s.empty? }
            .join(" | ")
        else
          # This is a hack to work around the way context objects are created for each
          # render environment. To make sure that a page_title set from inside a template
          # is still available in the layout, we default the page_title to an empty string
          # (see #initialize) and then _mutate it_ when a new title is set. Soooo bad but
          # it'll do for now, until we come up with a better approach inside hanami-view.
          _options[:page_title].replace new_title
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
