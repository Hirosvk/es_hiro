class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :body

  belongs_to :user
  belongs_to :owner, polymorphic: true

  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    mapping dynamic: false do
      indexes :body, type: 'text'
    end
  end

  def as_indexed_json(opts={})
    as_json(opts.merge(only: [:body]))
  end
end
