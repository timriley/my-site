module Database
  module Relations
    class Articles < ROM::Relation[:sql]
      schema :articles do
        attribute :id, Types::Serial
        attribute :path, Types::String # TODO: make this the primary key
        attribute :title, Types::String
        attribute :permalink, Types::String
        attribute :published_at, Types::Time.optional
        attribute :body, Types::String
      end
    end
  end
end
