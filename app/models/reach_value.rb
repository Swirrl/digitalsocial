class ReachValue

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/ReachValue'

  field :activity, 'http://data.digitalsocial.eu/def/ontology/activityForReach' # the activity we're discussing
  field :dataset, 'http://purl.org/linked-data/cube#DataSet' # always set to 'http://data.digitalsocial.eu/data/reach'
  field :measure_type, 'http://purl.org/linked-data/cube#measureType' # the question being answered.
  field :ref_period, 'http://data.digitalsocial.eu/def/ontology/reachRefPeriod', :datatype => RDF::XSD.dateTime # when the observation was made
  # NOTE: need to also have another triple, with the predicate of the object of the measure type triple

  def self.measure_type_xsd_type_for_activity_type(activity_type_slug)
    activity_type_slug == "other" ? RDF::XSD.string : RDF::XSD.integer
  end

  def self.question_text_for_activity_type(activity_type_slug)
    {
      "research-project" => "How many times have your research outputs been downloaded in the last year?",
      "event" => "How many people attended your event (the last time it was run)",
      "network" => "How many organizations or individuals do you have in your network?",
      "incubators-and-accelerators" => "How many projects were supported by your incubator or accelerator in the last year?",
      "maker-and-hacker-spaces" => "How many active members were supported by your maker or hacker space in the last year?",
      "education-and-training" => "How many people did your activity provide education or training to in the last year?",
      "service-delivery" => "How many users are registered for your services?",
      "investment-and-funding" => "How much investment or funding have you distributed in the last year? (in euros)",
      "advocating-and-campaigning" => "How many subscribers took part in your campaigns in the last year?",
      "advisory-or-expert-body" => "How many clients have you advised over the last year?",
      "other" => "Please describe the reach of your activity in as quantitative a way as possible."
    }[activity_type_slug]
  end

  def self.measure_type_unit_for_activity_type(activity_type_slug)
    activity_type_slug == "investment-and-funding" ? "http://dbpedia.org/resource/Euro" : nil
  end

  # given an activity type uri, get the measure type uri
  # opts:
  #   if the ActivityType is network,
  #     opts[:network_metric] can be organizations or individuals
  def self.get_measure_type_uri_for_activity_type(activity_type_slug, opts={})
    lookup_val = measure_type_slug_for_activity_type(activity_type_slug)

    if opts[:network_metric]
      reach_measure_type_slug = lookup_val[opts[:network_metric].to_s]
    else
      reach_measure_type_slug = lookup_val
    end

    "http://data.digitalsocial.eu/def/ontology/reach/#{reach_measure_type_slug}"
  end

  def self.get_reach_value_for_activity(activity_uri)
    # do a lookup with SPARQL
  end

  def self.build_reach_value(activity_resource, reachValueLiteral)

    measure_type_uri = ReachValue.get_measure_type_uri_for_activity_type(activity_resource.slug)

    rv = ReachValue.new
    rv.activity = activity_resource.uri
    rv.dataset = 'http://data.digitalsocial.eu/data/reach'
    rv.measure_type = measure_type_uri
    rv.ref_period = Time.now
    rv[measure_type_uri] = reachValueLiteral
    rv

  end

  private

  # map of Activity Types slugs to Reach Measure Type slugs
  def self.measure_type_slug_for_activity_type(activity_type_slug)
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
    }[activity_type_slug]
  end

end