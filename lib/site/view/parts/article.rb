# auto_register: false

require "dry/view/part"
require "commonmarker"

module Site
  module View
    module Parts
      class Article < Dry::View::Part
        def absolute_url
          external_url || "#{context.site_url}/writing/#{permalink}"
        end

        def url
          external_url || "/writing/#{permalink}"
        end

        def display_date
          published_at.strftime("%-m %B %Y")
        end

        def body_html
          @body_html ||= CommonMarker.render_html(body)
        end
      end
    end
  end
end
