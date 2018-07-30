config = YAML.load_file("config/elasticsearch.yml")[Rails.env].deep_symbolize_keys
Elasticsearch::Model.client = Elasticsearch::Client.new(config)
