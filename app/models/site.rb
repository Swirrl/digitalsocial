class Site

  include Tripod::Resource

  rdf_type 'http://www.w3.org/ns/org#Site'
  graph_uri Digitalsocial::DATA_GRAPH

  field :lat, 'http://www.w3.org/2003/01/geo/wgs84_pos#lat', :datatype => RDF::XSD.decimal
  field :lng, 'http://www.w3.org/2003/01/geo/wgs84_pos#long', :datatype => RDF::XSD.decimal
  field :address, 'http://www.w3.org/ns/org#siteAddress', is_uri: true

  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/site/#{Guid.new}")
  end

  before_save :round_lat_lng

  private

  def round_lat_lng
    # this is enough precision.
    self.lat = self.lat.to_f.round(6)
    self.lng = self.lng.to_f.round(6)
  end

end