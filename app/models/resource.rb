class Resource
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :body
  field :title

  has_many :notes, as: :owner

  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    mapping dynamic: false do
      indexes :body, type: 'text'
      indexes :title, type: 'text'
    end
  end

  def as_indexed_json(opts={})
    as_json(opts.merge(only: [:body, :title]))
  end
end
