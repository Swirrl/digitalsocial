class Concepts::TechnologyFocus

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/TechnologyFocus'

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/technology-focus/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/technology-focus'
  broad_concept_uri (resource_uri_root + 'other')

end