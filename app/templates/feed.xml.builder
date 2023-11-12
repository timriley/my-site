xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title site_title
  xml.link "href" => site_url
  xml.updated Time.now.iso8601 # make better
  xml.author do
    xml.name site_author
  end
  xml.id site_url

  articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => article.absolute_url
      xml.id article.absolute_url
      xml.published article.published_at.iso8601
      xml.updated article.published_at.iso8601
      xml.author do
        xml.name site_author
      end
      unless article.external_url
        xml.content article.body_html, "type" => "html"
      end
    end
  end
end
