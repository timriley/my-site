require "rom/struct"

module Site
  module Entities
    class Article < ROM::Struct
      def external?
        !external_url.nil?
      end
    end
  end
end
