class UniversalTextSearch
  # Including thse classes explicitly in search is necessary for #records method
  # to function properly (it tries to call #find method on the found document).
  # Without them, search itself works fine and it searches all indices, it's only when using
  # #records that can be a problem.
  SEARCH_CLASSES = [User, Note, Resource]

  def self.simple_text_search(text, opts={})
    # opts can include meta fields such as routing

    # searches all text & keyword fields in all classes (or indices)
    # More about simple_query_string: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html
    query = {
      query: {
        simple_query_string: {
          query: text
        }
      },
    }
    Elasticsearch::Model.search(query, SEARCH_CLASSES, opts)
  end

  def self.term_search(field_value, opts={})
    # searches exact match
    # More about term search: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-term-query.html
    query = {
      query: {
        term: field_value
      }
    }
    Elasticsearch::Model.search(query, SEARCH_CLASSES, opts)
  end

  # Elasticsearch::Model.search and Elasticsearch::Model.client.search very are different!
end
