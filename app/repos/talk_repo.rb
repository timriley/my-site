module Site
  module Repos
    class TalkRepo < Site::Repo[:talks]
      def all
        talks
          .by_date_descending
          .to_a
      end
    end
  end
end
