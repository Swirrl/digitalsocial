class TimeInterval

  include Tripod::Resource
  include TripodCache

  rdf_type 'http://purl.org/NET/c4dm/timeline.owl#Interval'
  graph_uri Digitalsocial::DATA_GRAPH

  field :start_date, 'http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime', datatype: RDF::XSD.dateTime
  field :end_date, 'http://purl.org/NET/c4dm/timeline.owl#endsAtDateTime', datatype: RDF::XSD.dateTime

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/timeline-interval/#{Guid.new}")
  end

end