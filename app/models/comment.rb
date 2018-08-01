class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model

  field :body, type: String

  belongs_to :account

  after_create  :es_index_document
  after_update  :es_update_document
  after_destroy :es_delete_document

  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    mappings dynamic: false do
      indexes :body
    end
  end

  def as_indexed_json
    as_json(only: [:body])
  end

  private
  def es_index_document(opts={})
    __elasticsearch__.index_document(opts)
  end

  def es_update_document(opts={})
    __elasticsearch__.update_document(opts)
  end

  def es_delete_document(opts={})
    __elasticsearch__.delete_document(opts)
  end
end
