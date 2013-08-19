class ConceptScheme

  include Tripod::Resource

  field :label, RDF::RDFS.label
  field :has_top_concept, RDF::SKOS.hasTopConcept, is_uri: true, multivalued: true

  rdf_type RDF::SKOS.ConceptScheme

  # note: don't restrict to graph
  # ... as in production the concept scheme itself will be defined in the metadata graph
end