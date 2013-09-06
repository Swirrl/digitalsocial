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

  # memoized getter for project resource, based on the uri in self.activity field.
  def project_resource
    @project ||= Project.find(self.activity)
  end

  def activity_type_slug
    project_resource.activity_type_slug
  end

  # getter and setter for the reah value literal
  ######

  # getter
  def reach_value_literal
    self.read_predicate(self.measure_type).first
  end

  # setter
  def reach_value_literal=(val)
    puts self.activity_type_slug
    data_type = self.activity_type_slug == "other" ? RDF::XSD.string : RDF::XSD.integer
    self.write_predicate(self.measure_type, RDF::Literal.new(val, :datatype => data_type) )
  end

  # lookup the latest reach value observation given a project
  def self.get_latest_reach_value_resource_for_activity(project_resource)
    activity_predicate = ReachValue.fields[:activity].predicate.to_s
    period_predicate = ReachValue.fields[:ref_period].predicate.to_s

    ReachValue.where("?uri <#{activity_predicate}> <#{project_resource.uri.to_s}>")
      .where("?uri <#{period_predicate}> ?period")
      .order("DESC(?period)")
      .first
  end

  # construct a reach value resource given a project, and a literal value
  def self.build_reach_value(project_resource, reach_value_literal)

    rv = ReachValue.new
    rv.activity = project_resource.uri
    rv.dataset = 'http://data.digitalsocial.eu/data/reach'
    rv.measure_type = ReachValue.determine_measure_type_uri(project_resource)
    rv.ref_period = DateTime.now
    rv.reach_value_literal = reach_value_literal

    rv
  end

  def self.determine_measure_type_uri(project_resource)
    network_metric = project_resource.network_metric(:new_resource => true)
    measure_type_uri = project_resource.activity_type_resource.get_reach_measure_type_uri(network_metric)
  end

end