module Site
  module Views
    class Writing < Site::View
      include Deps["repos.article_repo"]

      expose :articles do
        article_repo.published
      end
    end
  end
end
