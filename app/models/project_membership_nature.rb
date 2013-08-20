class ProjectMembershipNature

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/Role'

  include Tag
  uri_root 'http://data.digitalsocial.eu/def/concept/activity-role/'
  concept_scheme 'http://data.digitalsocial.eu/def/concept-scheme/activity-role'

end