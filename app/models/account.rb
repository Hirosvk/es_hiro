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

  # run Account.import && self.create_indexes

  settings index: {number_of_shards: 1, number_of_replicas: 2} do
    mappings dynamic: false do
      indexes :firstname, type: 'text'
      indexes :lastname, type: 'text'
      indexes :gender, type: 'text'
    end
  end

  # Account.search(query: {match: {firstname: 'john'}})

  def self.search_by_lastname(name)
    # this is how you do a multiple field query
    self.search(query: {
      match: {
        lastname: {
          query: name
        }
      }
    })
  end

  def self.search_by_firstname(name)
    # this is how you do a multiple field query
    self.search(query: {
      match: {
        firstname: {
          query: name
        }
      }
    })
  end

  def as_indexed_json
    # a necessary method to run self.import
    # with dynamic: false, it should just ignore extra fields,
    # however, when extra fields that are not part of settings declaration are present
    # it will not index the entire document.
    self.as_json(only: [:firstname, :lastname, :gender])
  end

  # can Solr do multi-index search? not sure...
  # documentation is poor with limited example on Elasticsearch, having to guess what actual api style like
  # index boost exist in Elasticsearch, not sure how scoping translates...
end
