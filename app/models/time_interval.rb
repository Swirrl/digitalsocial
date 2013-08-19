class TimeInterval

  include Tripod::Resource

  rdf_type 'http://purl.org/NET/c4dm/timeline.owl#Interval'
  graph_uri Digitalsocial::DATA_GRAPH

  field :start_date, 'http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime', datatype: RDF::XSD.date
  field :end_date, 'http://purl.org/NET/c4dm/timeline.owl#endsAtDateTime', datatype: RDF::XSD.date

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/timeline-interval/#{Guid.new}")
  end

end