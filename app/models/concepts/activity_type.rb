class Concepts::ActivityType

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/ActivityType'

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/activity-type/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/activity-type'
  concept_scheme_label 'ActivityTypes'

  broad_concept_uri (resource_uri_root + 'other')

  def slug
    self.uri.to_s.split('/').last
  end

  def get_reach_question_text
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
    }[self.slug]
  end

  def get_reach_label_text
    {
      "research-project" => "Downloads (in the last year)",
      "event" => "Attendees",
      "network" => "How many organizations or individuals do you have in your network?",
      "incubators-and-accelerators" => "Projects Supported (in the last year)",
      "maker-and-hacker-spaces" => "Active Members (in the last year)",
      "education-and-training" => "Students/Trainees (in the last year)",
      "service-delivery" => "Registered Users",
      "investment-and-funding" => "Investment/Funding Distributed in Euros (in the last year)",
      "advocating-and-campaigning" => "Participating Subscribers (in the last year)",
      "advisory-or-expert-body" => "Clients Advised (in the last year)",
      "other" => "Reach"
    }[self.slug]
  end

  # if the ActivityType is network, network_metric can be organizations or individuals
  def get_reach_measure_type_uri(network_metric=nil)
    lookup_val = {
      "research-project" => "downloads",
      "event" => "attendees",
      "network" => {"organisations" => "organizationMembers", "individuals" => "individualMembers"},
      "incubators-and-accelerators" => "projectsSupported",
      "maker-and-hacker-spaces" => "members",
      "education-and-training" => "individualsTrained",
      "service-delivery" => "registeredUsers",
      "investment-and-funding" => "fundsInvested",
      "advocating-and-campaigning" => "subscribers",
      "advisory-or-expert-body" => "clients",
      "other" => "description"
    }[self.slug]

    if self.slug == "network" && network_metric
      reach_measure_type_slug = lookup_val[network_metric.to_s]
    else
      reach_measure_type_slug = lookup_val
    end

    "http://data.digitalsocial.eu/def/ontology/reach/#{reach_measure_type_slug}"
  end


end