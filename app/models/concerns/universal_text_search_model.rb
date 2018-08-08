module UniversalTextSearchModel
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # Indexing of model instances do not happen automatically unless setup manually.
    # Elasticsearch::Callbacks takes care of these operations, but the maintainers of the gem seem
    # to be considering removing them all together and advocating for setting them up manually like below.
    # see https://github.com/elastic/elasticsearch-rails/issues/685
    # Doing these callbacks in asyc process i.e. Resque is recommended
    after_create  :es_index_document
    after_update  :es_update_document
    after_destroy :es_delete_document


    def self.search_by_field_name(field_name, value)
      # I wrote a few search methods here only to experiment.
      # I imagine methods in UniversalTextSearch adapter is more relevant to us.
      query = {
        query: {
          match: {
            field_name => {
              query: value
            }
          }
        }
      }
      search(query)
    end

    def self.reset!
      __elasticsearch__.delete_index! rescue nil
      __elasticsearch__.create_index!
      import
    end

    def self.method_missing(name, *args, &block)
      search_method = name.to_s.match(/(search_by_)(.*)/)
      field_name = search_method[2] rescue nil

      if search_method && fields.include?(field_name)
        search_by_field_name(field_name, *args)
      else
        super(name, *args, &block)
      end
    end
  end

  private
  # I prefixed these method names with 'es_' so that they don't conflict with mongoid methods.
  # (When I used the name :update_document, for example, it overrode mongoids' and
  # and caused unwanted behavior.)

  # Fails if it doesn't take 'opts' argument.
  # Elasticsearch skips index when un-indexed value is updated;
  # That kind of makes sense, but it still ignores when meta field is updated here
  # i.e. routing and doesn't update it unless indexed values are updated.
  def es_index_document(opts={})
    __elasticsearch__.index_document(opts.merge(routing: language))
  end

  def es_update_document(opts={})
    __elasticsearch__.update_document(opts.merge(routing: language))
  end

  def es_delete_document(opts={})
    __elasticsearch__.delete_document(opts.merge(routing: language))
  end
end
