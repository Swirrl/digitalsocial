class Concepts::AreaOfDigitalSocialInnovation

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/AreaOfDigitalSocialInnovation'

  include TripodCache

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/area-of-digital-social-innovation/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/area-of-digital-social-innovation'
  concept_scheme_label 'Areas Of Digital Social Innovation'
  broad_concept_uri (resource_uri_root + 'other')

end