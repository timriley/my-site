# auto_register: false

require "time"
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
          published_at.strftime("%Y/%m/%d")
        end

        def datetime_code
          published_at.utc.iso8601
        end

        def body_html
          @body_html ||= render_markdown(body)
        end

        private

        def render_markdown(str)
          doc = CommonMarker.render_doc(str, [:FOOTNOTES, :SMART])

          doc.walk do |node|
            if node.type == :image
              # node.url = context.asset_path(node.url)
              node.url = "/assets/#{node.url}"
            end
          end

          doc.to_html
        end
      end
    end
  end
end
