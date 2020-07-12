require "fileutils"
require "site/import"
require "dry/monads"
require "dry/monads/result"

module Site
  class Generate
    include Dry::Monads::Result::Mixin

    include Import[
      "settings",
      "repos.article_repo",
      about_view: "views.about",
      article_view: "views.article",
      export: "exporters.files",
      feed_view: "views.feed",
      home_view: "views.home",
      speaking_view: "views.speaking",
      writing_view: "views.writing",
    ]

    def call(root)
      export_dir = File.join(root, settings.export_dir)

      FileUtils.cp_r File.join(root, "assets/content"), File.join(export_dir, "assets/content")

      render export_dir, "index.html", home_view
      render export_dir, "writing/index.html", writing_view
      render export_dir, "feed.xml", feed_view
      render export_dir, "speaking/index.html", speaking_view
      render export_dir, "about/index.html", about_view

      article_repo.internal_published.each do |article|
        render export_dir, "writing/#{article.permalink}/index.html", article_view, article: article
      end

      Success()
    end

    private

    def render(export_dir, path, view, **input)
      context = view.class.config.context.new(current_path: path.sub(%r{/index.html$}, ""))

      export.(export_dir, path, view.(context: context, **input))
    end
  end
end
