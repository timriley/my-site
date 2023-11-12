module Site
  module Views
    class Article < Site::View
      include Deps["repos.article_repo"]

      expose :article, as: Views::Parts::Article do |slug:|
        article_repo.get_by_slug(slug)
      end
    end
  end
end
