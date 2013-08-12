class Organisation

  include Tripod::Resource

  rdf_type 'http://example.com/organisation'
  graph_uri 'http://example.com/dsi_data'

  field :name, 'http://example.com/name'
  field :primary_site, 'http://example.com/site', is_uri: true

  validates :name, presence: true
  
  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/organisation/#{Guid.new}")
  end

  def guid
    self.uri.to_s.split("/").last
  end
  
  def primary_site_resource
    Site.find(self.primary_site)
  end

  def projects
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    Project
      .where("?pm_uri <#{project_membership_org_predicate}> <#{self.uri}>")
      .where("?pm_uri <#{project_membership_project_predicate}> ?uri")
  end

  def project_resources
    projects.resources
  end

  def project_resource_uris
    projects.resources.collect { |p| p.uri.to_s }
  end

  def any_projects?
    projects.count > 0
  end

  # def requests
  #   Request.or({ sender: self.uri.to_s }, { receiver: self.uri.to_s })
  # end

  def pending_project_invites
    Request.where(requestor_type: 'Organisation', requestor_id: self.uri.to_s, responded_to: false, is_invite: true)
  end

  def pending_project_requests
    Request.where(requestor_type: 'Organisation', requestor_id: self.uri.to_s, responded_to: false, is_invite: false)
  end

  def respondable_project_requests
    Request.where(requestable_type: 'Project', responded_to: false, is_invite: false).in(requestable_id: project_resource_uris)
  end

  def can_edit_project?(project)
    project_creator_predicate = Project.fields[:creator].predicate.to_s
    
    Project
      .where("?uri <#{project_creator_predicate}> <#{self.uri}>")
      .where("FILTER (?uri = <#{project.uri}>)")
      .count > 0
  end

end