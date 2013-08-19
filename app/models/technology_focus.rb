class TechnologyFocus

  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/tech-focus'

  include Tag
  uri_root 'http://example.com/def/concept/tech-focus/'
  concept_scheme 'http://example.com/def/concept-scheme/tech-focus'

end