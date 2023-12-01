# auto_register: false

require "commonmarker"
require "hanami/view/part"
require "time"
require "uri"

module Site
  module Views
    module Parts
      class Article < Hanami::View::Part
        def absolute_url
          external_url || "#{context.site_url}/writing/#{permalink}"
        end

        def url
          external_url || "/writing/#{permalink}"
        end

        def external_url_domain
          return unless external?
          URI(external_url).host.sub(/^www\./, "")
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
          doc = CommonMarker.render_doc(str, [:FOOTNOTES, :SMART, :UNSAFE])

          doc.walk do |node|
            if node.type == :image
              next if URI(node.url).absolute?

              node.url = helpers.asset_url(node.url)
            end
          end

          doc.to_html(:UNSAFE)
        end
      end
    end
  end
end
