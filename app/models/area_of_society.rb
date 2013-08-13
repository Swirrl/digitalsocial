class AreaOfSociety

  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/area-of-society'

  include Tag
  uri_root 'http://example.com/def/concept/area-of-society/'
  concept_scheme 'http://example.com/def/concept-scheme/area-of-society'

end