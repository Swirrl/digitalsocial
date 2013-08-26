class Address
  include Tripod::Resource

  rdf_type 'http://www.w3.org/2006/vcard/ns#Address'
  graph_uri Digitalsocial::DATA_GRAPH

  field :street_address, 'http://www.w3.org/2006/vcard/ns#streetAddress'
  field :locality, 'http://www.w3.org/2006/vcard/ns#locality'
  field :region, 'http://www.w3.org/2006/vcard/ns#region'
  field :country, 'http://www.w3.org/2006/vcard/ns#country'
  field :postal_code, 'http://www.w3.org/2006/vcard/ns#postalCode'

  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/address/#{Guid.new}")
  end

  def to_s
    [street_address, locality, region, country, postal_code].select{|portion| portion.present?}.join(', ')
  end

end