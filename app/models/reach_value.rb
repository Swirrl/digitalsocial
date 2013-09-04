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
  def self.measure_type_for_activity_type(activity_type_slug)
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

  def self.measure_type_xsd_type_for_activity_type(activity_type_slug)
    activity_type_slug == "other" ? RDF::XSD.string : RDF::XSD.integer
  end

  def self.question_text_for_activity_type(activity_type_slug)
    {
      "research-project" => "How many times have your research outputs been downloaded in the last year?",
      "event" => "How many people attended your event (the last time it was run)",
      "network" => "How many organizations or individuals do you have in your network?",
      "incubators-and-accelerators" => "",
      "maker-and-hacker-spaces" => "",
      "education-and-training" => "",
      "service-delivery" => "",
      "investment-and-funding" => "",
      "advocating-and-campaigning" => "",
      "advisory-or-expert-body" => "",
      "other" => ""
    }
  end

  def self.measure_type_unit_for_activity_type(activity_type_slug)
    activity_type_slug == "investment-and-funding" ? "http://dbpedia.org/resource/Euro" : nil
  end

  # given an activity type uri, get the measure type uri
  # opts:
  #   if the ActivityType is network,
  #     opts[:network_metric] can be organizations or individuals
  def self.get_measure_type_uri_for_activity_type(activity_type_slug, opts={})
    lookup_val = ReachValue.measure_type_lookup[activity_type_slug]

    if opts[:network_metric]
      reach_measure_type_slug = lookup_val[opts[:network_metric].to_s]
    else
      reach_measure_type_slug = lookup_val
    end

    "http://data.digitalsocial.eu/def/ontology/reach/#{reach_measure_type_slug}"
  end



end