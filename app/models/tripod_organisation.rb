class TripodOrganisation

  include Tripod::Resource

  field :name, 'http://example.com/name'
  field :lat,  'http://example.com/lat'
  field :lng,  'http://example.com/lng'

  rdf_type 'http://example.com/organisation'
  graph_uri 'http://example.com/organisations'

end