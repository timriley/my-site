module Site
  module Views
    class Feed < Site::View
      include Site::Deps["settings", "repos.article_repo"]

      config.default_format = "xml"
      config.layout = false

      expose :articles, as: Views::Parts::Article do
        article_repo.published
      end

      expose :settings do
        settings
      end
    end
  end
end
