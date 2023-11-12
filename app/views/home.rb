module Site
  module Views
    class Home < Site::View
      include Deps["repos.article_repo"]

      configure do |config|
        config.template = "home"
      end

      expose :articles, as: Views::Parts::Article do
        article_repo.published(limit: 5)
      end
    end
  end
end
