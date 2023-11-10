require "site/repo"

module Site
  module Repos
    class ArticleRepo < Site::Repo[:articles]
      def get_by_slug(slug)
        articles.by_permalink(slug).one!
      end

      def published(limit: nil)
        articles
          .published
          .by_date_descending
          .yield_self { |a| limit ? a.limit(limit) : a }
          .to_a
      end

      def internal_published
        articles
          .published
          .internal
          .by_date_descending
          .to_a
      end
    end
  end
end
