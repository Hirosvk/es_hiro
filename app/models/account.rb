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

  # self.__elasticsearch__.delete_index!
  # self.__elasticsearch__.create_index!
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

  def as_indexed_json
    # a necessary method to run self.import.
    # make sure that this does not include _id field; it won't get indexed
    self.as_json(only: [:firstname, :lastname, :gender, :bio])
  end
end
