class Organisation

  include Tripod::Resource

  rdf_type 'http://example.com/organisation'
  graph_uri 'http://example.com/organisations'

  field :name, 'http://example.com/name'
  field :primary_site, 'http://example.com/site', is_uri: true
  
  def primary_site_resource
    Site.find(self.primary_site)
  end

end