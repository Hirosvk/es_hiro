class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :body, type: String
  belongs_to :account

  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    mapping dynamic: false do
      indexes :body, type: 'text'
    end
  end

  def as_indexed_json
    as_json(only: [:body])
  end
end
