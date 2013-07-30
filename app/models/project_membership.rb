class ProjectMembership

  include Tripod::Resource

  rdf_type 'http://example.com/project_membership'
  graph_uri 'http://example.com/dsi_data'

  field :organisation, 'http://example.com/def/project_membership/organisation', is_uri: true
  field :project, 'http://example.com/def/project_membership/project', is_uri: true
  field :nature, 'http://example.com/def/project_membership/nature', is_uri: true

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/project_membership/#{Guid.new}")
    self.rdf_type ||= ProjectMembership.rdf_type
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