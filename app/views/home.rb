module Site
  module Views
    class Home < Site::View
      include Deps["repos.article_repo"]

      expose :articles, as: Views::Parts::Article do
        article_repo.published(limit: 5)
      end
    end
  end
end
