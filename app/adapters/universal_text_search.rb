class UniversalTextSearch
  # Including thse classes explicitly in search is necessary for #records method
  # to function properly (it calls #find method on the found document).
  # Without them, search itself works fine, but it's just that #records doesnt' work.
  SEARCH_CLASSES = [User, Note, Resource]

  # A good summary of full text query types
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/full-text-queries.html

  # Examples:
  #   uts = UniversalTextSearch.match(:bio, 'society', {fuzziness: 'AUTO'}, {size: 10})
  #   uts.results.total         => 31
  #   uts.results               => Enumerables of 'Results' object is a that shows the content and metadata of the document
  #   uts.resutls.results.count => 10
  #   uts.records               => Mongo documents

  def self.match(field, text, opts={}, custom_meta_opts={})
    query = {
      query: {
        match: {
          field => {query: text}.merge(opts)
        }
      }
    }
    meta_opts = default_meta_opts.merge(custom_meta_opts)
    Elasticsearch::Model.search(query, SEARCH_CLASSES, meta_opts)
    # Elasticsearch::Model.search and Elasticsearch::Model.client.search very are different!
  end

  def self.multi_match(text, opts={}, custom_meta_opts={})
    query = {
      query: {
        multi_match: multi_match_opts(text).merge(opts)
      }
    }
    meta_opts = default_meta_opts.merge(custom_meta_opts)
    Elasticsearch::Model.search(query, SEARCH_CLASSES, meta_opts)
  end

  def self.multi_match_recent(text, opts={}, custom_meta_opts={})
    # This query gets all documents that match 'must' clause, and give a boost
    # to the ones that match 'should' clause.
    # I tried using 'boost' query with 'positive/negative' properties, but I could
    # not really get it to work, and I think using 'bool' with 'boost' property like this
    # makes clearer query.
    query = {
      query: {
        bool: {
          must: {multi_match: multi_match_opts(text).merge(opts)},
          should: [
            {range: {updated_at: {gte: 30.days.ago, boost: 2}}},
            {range: {updated_at: {gte: 90.days.ago, lt: 30.days.ago, boost: 1.5}}}
          ]
        }
      }
    }
    meta_opts = default_meta_opts.merge(custom_meta_opts)
    Elasticsearch::Model.search(query, SEARCH_CLASSES, meta_opts)
  end

  def self.multi_match_by_language(text, language, opts={}, custom_meta_opts={})
    query = {
      query: {
        bool: {
          must: [
            {multi_match: multi_match_opts(text).merge(opts)},
            {term: {language: language}}
          ]
        }
      }
    }
    meta_opts = default_meta_opts.merge(custom_meta_opts)
    # targetting only the shard that contains documents with this language
    meta_opts[:routing] = language
    Elasticsearch::Model.search(query, SEARCH_CLASSES, meta_opts)
  end

  def self.term_search(field, value, custom_meta_opts={})
    # searches exact match
    # Does not do 'exact match' against full text of 'text' fields, instead do 'exact match' against tokens
    # Does perform exact match against keywords.
    # More about term search: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-term-query.html
    query = {
      query: {
        term: {field => value}
      }
    }
    meta_opts = default_meta_opts.merge(custom_meta_opts)
    Elasticsearch::Model.search(query, SEARCH_CLASSES, meta_opts)
  end

  private

  def self.multi_match_opts(text)
    {
      query: text,
      fields: ['bio', 'body', 'title'],
      type: 'best_fields', # default
      fuzziness: 0 # default
    }
  end

  def self.default_meta_opts
    {
      size: 500
    }
  end

end
