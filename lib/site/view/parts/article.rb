# auto_register: false

require "dry/view/part"

module Site
  module View
    module Parts
      class Article < Dry::View::Part
        def url
          external_url || absolute_path
        end

        def absolute_path
          "/#{path}"
        end

        def display_date
          published_at.strftime("%-m %B %Y")
        end
      end
    end
  end
end
