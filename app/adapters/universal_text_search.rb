class UniversalTextSearch
  # including thse classes explicitly is necessary for #records method
  # to function properly (so that it can call #find method on the found document)
  SEARCH_CLASSES = [Account, Comment]

  def self.simple_text_search(text, size=10)
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
