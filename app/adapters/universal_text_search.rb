class UniversalTextSearch
  # Including thse classes explicitly in search is necessary for #records method
  # to function properly (it tries to call #find method on the found document).
  # Without them, search itself works fine and it searches all indices, it's only when using
  # #records that can be a problem.
  SEARCH_CLASSES = [User, Note, Resource]

  # A good summary of full text query types
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/full-text-queries.html
  # I imagine that we would need to use multi_match query for universal search

  # Note on method signature:
  # .results.total always show the accurate total but only includes 10 documents

  #   UniversalTextSearch.match(:bio, 'society', {size: 50, routing: 'vulcan'})
  def self.match(field, text, opts={}, meta_opts={})
    default_opts = {
      query: text,
      fuzziness: 0, # default
      auto_generate_synonyms_phrase_query: false # default
    }

    q = {
      query: {
        match: {
          field => default_opts.merge(opts)
        }
      }
    }
    opts[:size] ||= 500
    Elasticsearch::Model.search(q, SEARCH_CLASSES, opts)
  end

  def self.multi_match(text, opts={}, meta_opts={})
    default_opts = {
      query: text,
      fields: ['bio', 'body', 'title'],
      type: 'best_fields', # default
      fuzziness: 0 # default
    }

    q = {
      query: {
        multi_match: default_opts.merge(opts)
      }
    }
    meta_opts[:size] ||= 500
    Elasticsearch::Model.search(q, SEARCH_CLASSES, meta_opts)
  end

  def self.term_search(field, value, opts={})
    # searches exact match
    # More about term search: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-term-query.html
    query = {
      query: {
        term: {field => value}
      }
    }
    Elasticsearch::Model.search(query, SEARCH_CLASSES, opts)
  end

  # Elasticsearch::Model.search and Elasticsearch::Model.client.search very are different!
end
