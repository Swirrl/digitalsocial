class TimeInterval

  include Tripod::Resource

  rdf_type 'http://example.com/time_interval'
  graph_uri 'http://example.com/dsi_data'

  field :start_date, 'http://example.com/start_date', datatype: RDF::XSD.date
  field :end_date, 'http://example.com/end_date', datatype: RDF::XSD.date

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/time_interval/#{Guid.new}")
    self.rdf_type ||= TimeInterval.rdf_type
  end

end