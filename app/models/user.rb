class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include UniversalTextSearchModel

  field :firstname, type: String
  field :lastname, type: String
  field :age, type: Integer
  field :gender, type: String
  field :bio, type: String
  field :language, type: String # equivalent to :context

  has_many :notes

# These are inferred from class name, but can be modified or explicitly defined.
#   index_name "accounts"
#   document_type "account" # => becomes _type field of the document in ES

  settings index: {number_of_shards: 3, number_of_replicas: 1} do
    # :dynamic is set to true by default, which automatically indexes all fields returned by as_indexed_json.
    # However, even when :dynamic is set to false, I found that elasticsearch indexes
    # fields that are not in this decleration anyways.
    # According do their docs, fields that are not in the declarations are to supposed to be ignored
    # as long as :dynamnic is set to false. Hmmm....

    mappings dynamic: false do
      # 'text' fields are analyzed and tokenized at index time, and mapped by the individual tokens.
      # 'keywords' are indexed as they are (capitalization is preserved, too)
      indexes :firstname, type: 'keyword'
      indexes :lastname, type: 'keyword'
      indexes :language, type: 'keyword'

      indexes :updated_at, type: 'date'

      # It's important to specify the analyzer for text. The default, standard analyzer
      # does not tokenize english words correctly i.e. 'teaches' -> 'teach'
      #
      # Default index_options for analyzed string field is 'positions'. I'm not
      # sure if leveling it up to 'offsets' is necessary, and how much it hurts memory/disk space
      indexes :bio, type: 'text', analyzer: 'english', index_options: 'offsets'
    end
  end


  def as_indexed_json(opts={})
    # What this method returns is indexed in Elasticsearch.
    # It needs to take opts.
    #
    # On their github README, when they use SQL, they explicitly include :id in this,
    # but on their mongoid example, they explicitly exclude :_id & :id fields, with no explanation to why.
    # ES ignores indexing the whole document when :_id field is included in this json.
    # But, it automatically creates :_id field that corresponds to mongo's doc id.
    self.as_json(opts.merge(only: [:firstname, :lastname, :bio, :language, :updated_at]))
  end
end
