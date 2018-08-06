class Resource
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :body
  field :title

  has_many :notes, as: :owner

  settings index: {number_of_shards: 3, number_of_replicas: 1} do
    mapping dynamic: false do
      indexes :body, type: 'text', analyzer: 'english', index_options: 'offsets'
      indexes :title, type: 'text', analyzer: 'english', index_options: 'offsets'
      indexes :language, type: 'keyword'
    end
  end

  def as_indexed_json(opts={})
    as_json(opts.merge(only: [:body, :title, :language]))
  end
end
