# frozen_string_literal: true

module Site
  module Actions
    class Article < Site::Action
      include Deps["repos.article_repo"]

      def each
        article_repo.published.each do |article|
          yield({slug: article.permalink})
        end
      end
    end
  end
end
