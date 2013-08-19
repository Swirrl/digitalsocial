class ProjectMembership

  include Tripod::Resource

  rdf_type 'http://data.digitalsocial.eu/def/ontology/ActivityMembership'
  graph_uri Digitalsocial::DATA_GRAPH

  field :organisation, 'http://data.digitalsocial.eu/def/ontology/organisation', is_uri: true
  field :project, 'http://data.digitalsocial.eu/def/ontology/activity', is_uri: true
  field :nature, 'http://data.digitalsocial.eu/def/ontology/role', is_uri: true

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/activity-membership/#{Guid.new}")
  end

  def project_resource
    Project.find(self.project)
  end

  def organisation_resource
    Organisation.find(self.organisation)
  end

  def nature_resource
    ProjectMembershipNature.find(self.nature)
  end

end