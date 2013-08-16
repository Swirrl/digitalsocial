class ProjectMembershipNature

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/Role'
  graph_uri Digitalsocial::DATA_GRAPH

  field :label, 'http://www.w3.org/2000/01/rdf-schema#label'

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/project_membership_nature/#{Guid.new}")
  end

  def self.lead
    self.where("?uri <http://example.com/label> 'Lead'")
  end

end