module Database
  module Relations
    class Articles < ROM::Relation[:sql]
      schema :articles do
        attribute :id, Types::Serial
        attribute :path, Types::String
        attribute :title, Types::String
        attribute :permalink, Types::String
        attribute :published_at, Types::Time.optional
        attribute :body, Types::String
        attribute :external_url, Types::String.optional

        indexes do
          index :path, name: :unique_path, unique: true
          index :permalink, name: :unique_permalink, unique: true
        end
      end

      def published
        where { !published_at.is(nil) }
      end

      def by_date_descending
        order(self[:published_at].desc)
      end
    end
  end
end
