class Concepts::AreaOfSociety

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/AreaOfSociety'

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/area-of-society/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/area-of-society'
  concept_scheme_label 'Areas Of Society'
  broad_concept_uri (resource_uri_root + 'other')

end