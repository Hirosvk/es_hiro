class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model

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

#  This is inferred from class name, which will become _type field of the
#  indexed document. Can be modified (i.e. sharing same index across models)
#  document_type "account"

  # These operataions do not happen unless setup manually
  #  https://github.com/elastic/elasticsearch-rails/issues/685
  after_create  :es_index_document
  after_update  :es_update_document
  after_destroy :es_delete_document

  # Refresh entire index
  # self.__elasticsearch__.delete_index!
  # self.__elasticsearch__.create_index!
  #   (do this before indexing any document so that settings here is respected)
  # self.import

  # we need to run ES instances at least the number of replicas
  # i.e. with 1 replicas -> 2 ES nodes
  # shards number cannot be reconfigured without reindexing
  settings index: {number_of_shards: 1, number_of_replicas: 1} do
    # defualt is dynamic: true, which index all new fields;
    # However, even with dynamic: false, elasticsearch indexes all the fields given by as_indexed_json
    # It seems to respect as_indexed_json data more than what's specified here.
    mappings dynamic: false do
      indexes :firstname, type: 'text'
      indexes :lastname, type: 'text'
      indexes :gender, type: 'text'
      indexes :bio, type: 'text'
    end
    # type: 'string' is now deprecated.
  end

  # Account.search(query: {match: {firstname: 'john'}})

  def self.search_by_field_name(field_name, value)
    # this is how you do a multiple field query
    search(query: {
      match: {
        field_name => {
          query: value
        }
      }
    })
  end

  def self.method_missing(name, *args, &block)
    _name = name.to_s.match(/(search_by_)(.*)/)
    if _name && fields.include?(_name[2])
      search_by_field_name(_name[2], args[0])
    else
      super(name, *args, &block)
    end
  end

  def as_indexed_json(opts={})
    # a necessary method for many operations (:import, index_document, etc..)
    # It needs to take opts
    # Make sure that this does not include _id field; it won't get indexed
    # But the same _id IS indexed in ES.
    self.as_json(opts.merge(only: [:firstname, :lastname, :gender, :bio]))
  end

  private

  # Take a notice on 'routing' flag, which could speed up query

  # prefixed these method names so that they don't crash with mongoid methods.
  # (When I used the name :update_document, it overrode mongoids'.)

  # able to take 'opts' argument is important
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
