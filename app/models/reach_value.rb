class ReachValue

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/ReachValue'

  field :activity, 'http://data.digitalsocial.eu/def/ontology/activityForReach' # the activity we're discussing
  field :dataset, 'http://purl.org/linked-data/cube#DataSet' # always set to 'http://data.digitalsocial.eu/data/reach'
  field :measure_type, 'http://purl.org/linked-data/cube#measureType' # the question being answered.
  field :ref_period, 'http://data.digitalsocial.eu/def/ontology/reachRefPeriod' # when the observation was made

  # need to also have another triple, with the predicate of the object of the measure type triple
  # it's type will depend on the

  # map of Activity Types slugs to Reach Measure Type slugs
  def self.measure_type_lookup
    {
      "research-project" => "downloads",
      "event" => "attendees",
      "network" => {"organizations" => "organizationMembers", "individuals" => "individualMembers"},
      "incubators-and-accelerators" => "projectsSupported",
      "maker-and-hacker-spaces" => "members",
      "education-and-training" => "individualsTrained",
      "service-delivery" => "registeredUsers",
      "investment-and-funding" => "fundsInvested",
      "advocating-and-campaigning" => "subscribers",
      "advisory-or-expert-body" => "clients",
      "other" => "description"
    }
  end

  def self.measure_type_type
    {
      "research-project" => RDF::XSD.integer,
      "event" => RDF::XSD.integer,
      "network" => RDF::XSD.integer,
      "incubators-and-accelerators" => RDF::XSD.integer,
      "maker-and-hacker-spaces" => RDF::XSD.integer,
      "education-and-training" => RDF::XSD.integer,
      "service-delivery" => RDF::XSD.integer,
      "investment-and-funding" => RDF::XSD.integer,
      "advocating-and-campaigning" => RDF::XSD.integer,
      "advisory-or-expert-body" => RDF::XSD.integer,
      "other" => RDF::XSD.string,
    }
  end

  def self.measure_type_unit
    {
      "investment-and-funding" => "http://dbpedia.org/resource/Euro",
    }
  end

  # given an activity type uri, get the measure type uri
  # opts:
  #   if the ActivityType is network,
  #     opts[:network_metric] can be organizations or individuals
  def self.get_measure_type_for_activity_type(activity_type_uri, opts={})
    activity_type_slug = activity_type_uri.split('/')
    lookup_val = ReachValue.measure_type_lookup[activity_type_slug]

    if opts[:network_metric]
      reach_measure_type_slug = lookup_val[opts[:network_metric].to_s]
    else
      reach_measure_type_slug = lookup_val
    end

    "http://data.digitalsocial.eu/def/ontology/reach/#{reach_measure_type_slug}"
  end



end