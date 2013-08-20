class OrganisationType

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/OrganizationType'

  include Tag
  uri_root 'http://data.digitalsocial.eu/def/concept/organization-type/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/organization-type'

end