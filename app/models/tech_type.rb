class TechType

  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/tech-type'

  include Tag
  uri_root 'http://example.com/def/concept/tech-type/'
  concept_scheme 'http://example.com/def/concept-scheme/tech-type'

end