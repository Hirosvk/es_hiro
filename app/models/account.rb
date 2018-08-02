class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :account_number, type: Integer
  field :balance, type: Integer
  field :firstname, type: String
  field :lastname, type: String
  field :age, type: Integer
  field :gender, type: String
  field :address, type: String
  field :employer, type: String
  field :email, type: String
  field :city, type: String
  field :state, type: String
  field :bio, type: String

  has_many :comments

# we need to run ES instances at least the number of replicas
# i.e. with 1 replicas -> 2 ES nodes
# shards number cannot be reconfigured but replicas can
  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    # defualt is dynamic: true, which automatically indexes all fields returned by as_indexed_json
    # However, even with dynamic: false, I found that elasticsearch indexes all the fields anyways although
    # according do their docs, fields that are not in the declarations are to be ignored.
    # It seems to respect what as_indexed_json returns more than what's specified here.
    # ES is supposed to automatically detect types.
      mappings dynamic: false do
        indexes :firstname, type: 'text'
        indexes :lastname, type: 'text'
        indexes :gender, type: 'text'
        indexes :bio, type: 'text'
      end
    # type: 'string' is now deprecated.
  end


#  These are inferred from class name, but can be modified or explicitly defined.
#    index_name "universal_text_search"
#    document_type "account" # => becomes _type field of the document in ES

  def as_indexed_json(opts={})
    # a necessary method for many operations (:import, index_document, etc..)
    # What this method returns are indexed in Elasticsearch.
    # It needs to take opts.
    # ES does not index the document when :_id field is included in this json.
    # However, it automatically creates :_id field
    self.as_json(opts.merge(only: [:firstname, :lastname, :gender, :bio]))
  end

end
