class ReachValue

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/ReachValue'
  graph_uri Digitalsocial::DATA_GRAPH

  field :activity, 'http://data.digitalsocial.eu/def/ontology/activityForReach', :is_uri => true # the activity we're discussing
  field :dataset, 'http://purl.org/linked-data/cube#dataSet', :is_uri => true # always set to 'http://data.digitalsocial.eu/data/reach'
  field :measure_type, 'http://purl.org/linked-data/cube#measureType', :is_uri => true # the question being answered.
  field :ref_period, 'http://data.digitalsocial.eu/def/ontology/reachRefPeriod', :datatype => RDF::XSD.dateTime # when the observation was made
  # NOTE: need to also have another triple, with the predicate of the object of the measure type triple

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/data/reach/#{Guid.new}")
  end

  def self.measure_type_unit_for_activity_type(activity_type_slug)
    activity_type_slug == "investment-and-funding" ? "http://dbpedia.org/resource/Euro" : nil
  end

  def project_resource
    @project ||= Project.find(activity)
  end

  # the measure type uri used for this reach value resource
  def measure_type_uri
    return @measure_type_uri if @measure_type_uri

    if self.persisted?
      rmt = ReachMeasureType
        .where("<#{self.uri.to_s}> <http://purl.org/linked-data/cube#measureType> ?uri")
        .first
      @measure_type_uri = rmt.uri.to_s if rmt
    else
      @measure_type_uri
    end
  end

  # set hte measure type used for this resource
  def measure_type_uri=(val)
    @measure_type_uri=val
  end

  def get_reach_value_literal
    if self.measure_type_uri
      self.read_predicate(measure_type_uri).first
    end
  end

  def self.get_latest_reach_value_resource_for_activity(project_resource)
    activity_predicate = ReachValue.fields[:activity].predicate.to_s
    period_predicate = ReachValue.fields[:ref_period].predicate.to_s

    ReachValue.where("?uri <#{activity_predicate}> <#{project_resource.uri.to_s}>")
      .where("?uri <#{period_predicate}> ?period")
      .order("DESC(?period)")
      .first
  end

  # if the ActivityType is network, network_metric can be organizations or individuals
  def self.build_reach_value(project_resource, reach_value_literal)

    measure_type_uri = project_resource.activity_type_resource.get_reach_measure_type_uri(project_resource.network_metric(:new_resource => true))

    rv = ReachValue.new
    rv.activity = project_resource.uri
    rv.dataset = 'http://data.digitalsocial.eu/data/reach'
    rv.measure_type = measure_type_uri
    rv.ref_period = Time.now

    #these aren't saved as a field, just stored in memory.
    rv.measure_type_uri = measure_type_uri

    data_type = project_resource.activity_type_slug == "other" ? RDF::XSD.string : RDF::XSD.integer

    rv.write_predicate(measure_type_uri, RDF::Literal.new(reach_value_literal, :datatype => data_type) )

    rv
  end



end