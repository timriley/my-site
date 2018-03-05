---
title: Displaying both local and HTTP remote images in Prince XML generated PDFs
permalink: 2008/06/27/displaying-both-local-and-http-remote-images-in-prince-xml-generated-pdfs
published_at: 2008-06-27 04:30:00 +0000
---

In our Rails apps, we use the awesome [Prince XML](http://princexml.com/) to generate PDFs. We interact with the prince command line application using the [Ruby library and Rails helper](http://sublog.subimage.com/articles/2007/05/29/html-css-to-pdf-using-ruby-on-rails) from the guys over at subimage interactive.

When using their helper to generate a PDF from a Rails template, all image tags have the src attribute altered so they point to paths that are relative to the local filesystem, not just the root of your application.

However, this breaks any images that you are loading from remote locations over HTTP. For us, this ended up breaking the [static Google Maps](http://code.google.com/apis/maps/documentation/staticmaps/) that we were generating.

So here's an updated make\_pdf helper that only modifies the image paths if they are local. This lets us use both local and HTTP-hosted images on the same PDF!

```
# We use this chunk of controller code all over to generate PDF files.
#
# To stay DRY we placed it here instead of repeating it all over the place.
#
module PdfHelper
  require 'prince'

  private
    # Makes a pdf, returns it as data...
    def make_pdf(template_path, pdf_name, landscape=false)
      prince = Prince.new()
      # Sets style sheets on PDF renderer.
      prince.add_style_sheets(
        "#{RAILS_ROOT}/public/stylesheets/application.css",
        "#{RAILS_ROOT}/public/stylesheets/print.css",
        "#{RAILS_ROOT}/public/stylesheets/prince.css"
      )
      prince.add_style_sheets("#{RAILS_ROOT}/public/stylesheets/prince_landscape.css") if landscape
      # Render the estimate to a big html string.
      # Set RAILS_ASSET_ID to blank string or rails appends some time after
      # to prevent file caching, and messing up local-disk requests.
      ENV["RAILS_ASSET_ID"] = ''
      html_string = render_to_string(:template => template_path, :layout => 'document')
      # Make all paths relative to the file systemm, but only if they don't have http(s):// at the start.
      html_string.gsub!(%r{(src=")([^h][^t][^t][^p][^s]?[^:][^/]*)}, "src=\"#{RAILS_ROOT}/public\\2")
      # Send the generated PDF file from our html string.
      return prince.pdf_from_string(html_string)
    end

    # Makes and sends a pdf to the browser
    #
    def make_and_send_pdf(template_path, pdf_name, landscape=false)
      send_data(
        make_pdf(template_path, pdf_name, landscape),
        :filename => pdf_name,
        :type => 'application/pdf'
      )
    end
end
```

And just to be precise, here is the diff between the helpers:

```
--- pdf_helper.rb 2008-06-27 15:05:44.000000000 +1000
+++ new_pdf_helper.rb 2008-06-27 15:05:54.000000000 +1000
@@ -18,11 +18,11 @@
       prince.add_style_sheets("#{RAILS_ROOT}/public/stylesheets/prince_landscape.css") if landscape
       # Render the estimate to a big html string.
       # Set RAILS_ASSET_ID to blank string or rails appends some time after
- # to prevent file caching, fucking up local - disk requests.
+ # to prevent file caching, and messing up local-disk requests.
       ENV["RAILS_ASSET_ID"] = ''
       html_string = render_to_string(:template => template_path, :layout => 'document')
- # Make all paths relative, on disk paths...
- html_string.gsub!("src=\"", "src=\"#{RAILS_ROOT}/public")
+ # Make all paths relative to the file systemm, but only if they don't have http(s):// at the start.
+ html_string.gsub!(%r{(src=")([^h][^t][^t][^p][^s]?[^:][^/]*)}, "src=\"#{RAILS_ROOT}/public\\2")
       # Send the generated PDF file from our html string.
       return prince.pdf_from_string(html_string)
     end
```

I'd also love it if you could propose a better way to handle the regular expression inside the gsub! call. Leave a comment!

