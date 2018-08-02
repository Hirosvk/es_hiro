class UniversalTextSearch
  # Including thse classes explicitly in search is necessary for #records method
  # to function properly (it tries to call #find method on the found document).
  # Without them, search itself works fine and it searches all indices, it's only when using
  # #records.
  SEARCH_CLASSES = [User, Note, Resource]

  def self.simple_text_search(text, size=10)
    # searches all text fields in all classes (or indices)
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html
    query = {
      query: {
        simple_query_string: {
          query: text
        }
      },
      size: size
    }
    Elasticsearch::Model.search(query, SEARCH_CLASSES)
  end
end
