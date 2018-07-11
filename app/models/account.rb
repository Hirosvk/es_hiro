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

  settings index: {number_of_shards: 1} do
    mappings dynamic: 'false' do
      indexes :firstname, type: 'string'
      indexes :lastname, type: 'string'
      indexes :gender, type: 'string'
    end
  end

  # Account.search(query: {match: {firstname: 'john'}})

  def self.serach_a
    # this is how you do a multiple field query
    self.search(query: {
      match: {
        firstname: {
          query: "Amber"
        }
        gender: {
          queyr: "F"
        }
      }
    })
  end

  def as_indexed_json
    # a necessary method to run self.import
    self.as_json(only: [:firstname, :lastname, :gender])
  end

  # can Solr do multi-index search? not sure...
  # documentation is poor with limited example on Elasticsearch, having to guess what actual api style like
  # index boost exist in Elasticsearch, not sure how scoping translates...
end
