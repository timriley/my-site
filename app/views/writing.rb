module Site
  module Views
    class Writing < Site::View
      include Deps["repos.article_repo"]

      configure do |config|
        config.template = "writing"
      end

      expose :articles, as: Views::Parts::Article do
        article_repo.published
      end
    end
  end
end
