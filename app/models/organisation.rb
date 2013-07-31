class Organisation

  include Tripod::Resource

  rdf_type 'http://example.com/organisation'
  graph_uri 'http://example.com/dsi_data'

  field :name, 'http://example.com/name'
  field :primary_site, 'http://example.com/site', is_uri: true
  
  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/organisation/#{Guid.new}")
    self.rdf_type ||= Organisation.rdf_type
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

  def any_projects?
    projects.count > 0
  end

  def can_edit_project?(project)
    project_creator_predicate = Project.fields[:creator].predicate.to_s
    
    Project
      .where("?uri <#{project_creator_predicate}> <#{self.uri}>")
      .where("FILTER (?uri = <#{project.uri}>)")
      .count > 0
  end

end