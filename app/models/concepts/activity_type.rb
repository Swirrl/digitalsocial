class Concepts::ActivityType

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/ActivityType'

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/activity-type/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/activity-type'
  broad_concept_uri (resource_uri_root + 'other')

  def slug
    self.uri.to_s.split('/').last
  end
end