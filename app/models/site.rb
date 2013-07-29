class Site

  include Tripod::Resource

  rdf_type 'http://example.com/site'
  graph_uri 'http://example.com/sites'

  field :lat, 'http://example.com/lat'
  field :lng, 'http://example.com/lng'

end