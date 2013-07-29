class ProjectMembership

  include Tripod::Resource

  rdf_type 'http://example.com/project_membership'
  graph_uri 'http://example.com/project_memberships'

  field :organisation, 'http://example.com/organisation'
  field :project, 'http://example.com/project'

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

end