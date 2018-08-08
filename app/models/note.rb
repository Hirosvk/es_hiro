class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :body, type: String
  field :language, type: String # equivalent to :context

  belongs_to :user
  belongs_to :owner, polymorphic: true

  settings index: {number_of_shards: 3, number_of_replicas: 1} do
    mapping dynamic: false do
      indexes :body, type: 'text', analyzer: 'english', index_options: 'offsets'
      indexes :language, type: 'keyword'
      indexes :updated_at, type: 'date'
    end
  end

  def as_indexed_json(opts={})
    as_json(opts.merge(only: [:body, :language, :updated_at]))
  end
end
