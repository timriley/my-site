# frozen_string_literal: true

require "site/action"

module Site
  module Actions
    class Article < Site::Action
      include Deps["repos.article_repo"]

      def each
        article_repo.published.each do |article|
          yield({slug: article.permalink})
        end
      end

      # def generate_each
      #   article_repo.published.each do |article|
      #     slug = article.permalink
      #     yield [{slug: slug}, view.(slug: slug)]
      #   end
      # end
    end
  end
end
