class Concepts::ProjectMembershipNature

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/Role'

  include TripodCache

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/activity-role/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/activity-role'
  concept_scheme_label 'Activity Roles'

end