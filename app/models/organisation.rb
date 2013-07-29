class Organisation

  include Tripod::Resource

  rdf_type 'http://example.com/organisation'
  graph_uri 'http://example.com/organisations'

  field :name, 'http://example.com/name'
  #field :lat, 'http://example.com/name'
  #field :lng, 'http://example.com/name'
   

end