class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :firstname, type: String
  field :lastname, type: String
  field :age, type: Integer
  field :gender, type: String
  field :bio, type: String

  has_many :notes

# we need to run ES instances at least the number of replicas
# i.e. with 1 replicas -> 2 ES nodes
# shards number cannot be reconfigured but replicas can
  settings index: {number_of_shards: 3, number_of_replicas: 1} do
    # defualt is dynamic: true, which automatically indexes all fields returned by as_indexed_json
    # However, even with dynamic: false, I found that elasticsearch indexes all the fields anyways although
    # according do their docs, fields that are not in the declarations are to be ignored.
    # It seems to respect what as_indexed_json returns more than what's specified here.
    # ES is supposed to automatically detect types.

      mappings dynamic: false do
        # text fields are searched through analyzer. keywords are not.
        indexes :firstname, type: 'keyword'
        indexes :lastname, type: 'keyword'
        indexes :bio, type: 'text'
        indexes :language, type: 'keyword'
      end
    # type: 'string' is now deprecated.
  end


#  These are inferred from class name, but can be modified or explicitly defined.
#    index_name "accounts"
#    document_type "account" # => becomes _type field of the document in ES

  def as_indexed_json(opts={})
    # a necessary method for many operations (:import, index_document, etc..)
    # The fields this method returns are indexed in Elasticsearch.
    # It needs to take opts.
    # ES ignores the document when :_id field is included in this json.
    # (Though it automatically creates :_id field, and it's indexed in ES)
    # On their github readme, when they use SQL, they include :id, while one their
    # mongoid example, they explicitly exclude :_id & :id fields, with no explanation.
    self.as_json(opts.merge(only: [:firstname, :lastname, :bio, :language]))
  end
end
