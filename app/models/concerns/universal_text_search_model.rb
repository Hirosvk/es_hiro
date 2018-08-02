module UniversalTextSearchModel
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

  # For the purpose of universal text search, I was wondering if we should have one index field,
  # and all documents are stored under it, then when we search, it searches one index;
  # or, each class has their own index, and when we search, search multiple indexes (which
  # is supposed to be easily done in ES).
  #
  # Found an answer here: https://www.elastic.co/blog/index-type-parent-child-join-now-future-in-elasticsearch
  # "Multiple types in the same index really shouldn't be used all that often and one of the few use cases for types is parent child relationships."


  # These operataions do not happen unless setup manually.
  # Elasticsearch::Callbacks takes care of these operations, but the maintainers of the lib seem
  # to be considering removing them and advocating for setting them up manually like this.
  # see https://github.com/elastic/elasticsearch-rails/issues/685
    after_create  :es_index_document
    after_update  :es_update_document
    after_destroy :es_delete_document

    def self.search_by_field_name(field_name, value)
      query = {
        query: {
          match: {
            field_name => {
              query: value
            }
          }
        }
      }
      search(query).records
      # #records return the search results as Rails model instances.
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

    def self.reset!
      __elasticsearch__.delete_index!
      __elasticsearch__.create_index!
      import
    end

  end

  private

  # Take a notice on 'routing' flag, which could speed up query

  # I prefixed these method names so that they don't conflict with mongoid methods.
  # (When I used the name :update_document, for example, it overrode mongoids' and
  # and caused unexpected behavior.)

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
