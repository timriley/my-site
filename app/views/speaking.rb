module Site
  module Views
    class Speaking < Site::View
      include Deps["repos.talk_repo"]

      expose :upcoming_talks do |talks|
        talks.select { |talk| talk.date > Time.now }.sort_by { _1.date }
      end

      expose :past_talks do |talks|
        talks.select { |talk| talk.date < Time.now }
      end

      private

      private_expose def talks
        talk_repo.all
      end
    end
  end
end
