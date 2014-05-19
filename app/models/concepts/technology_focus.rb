class Concepts::TechnologyFocus

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/TechnologyFocus'

  include TripodCache

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/technology-focus/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/technology-focus'
  broad_concept_uri (resource_uri_root + 'other')
  concept_scheme_label 'Activity Technology Focuses'

  def get_view_label
    "#{self.label} <span style='display:block; font-weight:lighter; color:rgba(255,255,255,0.7); font-size: 16px; line-height: 1.2; margin-top: 3px;'>(#{self.description})</span>".html_safe
  end

end