class ProjectMembershipNature

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/Role'
  graph_uri Digitalsocial::DATA_GRAPH

  field :label, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :sub_class_of, RDF::RDFS.subClassOf, is_uri: true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/def/concept/activity-role/#{Guid.new}")
    self.sub_class_of = RDF::SKOS.Concept
  end

end