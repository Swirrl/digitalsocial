class ActivityType

  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/activity-type'

  include Tag
  uri_root 'http://example.com/def/concept/activity-type/'
  concept_scheme 'http://example.com/def/concept-scheme/activity-type'

end