class Site

  include Tripod::Resource

  rdf_type 'http://example.com/site'
  graph_uri 'http://example.com/dsi_data'

  field :lat, 'http://example.com/lat'
  field :lng, 'http://example.com/lng'

end