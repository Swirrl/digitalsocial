class TechnologyMethod

  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/tech-method'

  include Tag
  uri_root 'http://example.com/def/concept/tech-method/'
  concept_scheme 'http://example.com/def/concept-scheme/tech-method'

end