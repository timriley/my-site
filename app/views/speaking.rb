module Site
  module Views
    class Speaking < Site::View
      include Deps["repos.talk_repo"]

      configure do |config|
        config.template = "speaking"
      end

      expose :upcoming_talks, as: Views::Parts::Talk do |talks|
        talks.select { |talk| talk.date > Time.now }
      end

      expose :past_talks, as: Views::Parts::Talk do |talks|
        talks.select { |talk| talk.date < Time.now }
      end

      private

      private_expose def talks
        talk_repo.all
      end
    end
  end
end
