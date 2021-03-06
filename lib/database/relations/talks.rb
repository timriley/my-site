module Database
  module Relations
    class Talks < ROM::Relation[:sql]
      schema :talks do
        attribute :id, Types::Serial
        attribute :path, Types::String
        attribute :title, Types::String
        attribute :url, Types::String.optional
        attribute :event, Types::String
        attribute :event_url, Types::String.optional
        attribute :location, Types::String
        attribute :date, Types::Time
        attribute :body, Types::String
      end

      def by_date_descending
        order(self[:date].desc)
      end
    end
  end
end
