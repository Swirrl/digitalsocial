class Organisation

  include Tripod::Resource

  rdf_type 'http://www.w3.org/ns/org#Organisation'
  graph_uri Digitalsocial::DATA_GRAPH

  field :name, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :primary_site, 'http://www.w3.org/ns/org#hasPrimarySite', is_uri: true

  field :no_of_staff, 'http://data.digitalsocial.eu/def/ontology/numberOfFTEStaff', datatype: RDF::XSD.integer
  field :twitter, 'http://data.digitalsocial.eu/def/ontology/twitterAccount', is_uri: true # this should be the full URL http://twitter.com/blah

  validates :name, presence: true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/organization/#{Guid.new}")
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def primary_site_resource
    Site.find(self.primary_site) if self.primary_site
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

  # Pending project invites for this organisation that can be responded to
  def respondable_project_invites
    ProjectRequest.where(requestor_type: 'Organisation', requestor_id: self.uri.to_s, responded_to: false, is_invite: true)
  end

  # Pending project requests made by another organisation to join one of this organisation's projects
  def respondable_project_requests
    ProjectRequest.where(requestable_type: 'Project', responded_to: false, is_invite: false).in(requestable_id: project_resource_uris)
  end

  def respondable_user_requests
    UserRequest.where(responded_to: false, requestable_id: self.uri.to_s)
  end

  def has_respondables?
    has_respondable_project_invites? || has_respondable_project_requests? || has_respondable_user_requests?
  end

  def has_respondable_project_invites?
    respondable_project_invites.count > 0
  end

  def has_respondable_project_requests?
    respondable_project_requests.count > 0
  end

  def has_respondable_user_requests?
    respondable_user_requests.count > 0
  end

  def can_edit_project?(project)
    true # everyone can edit project for now.
  end

  def as_json(options = nil)
    json = {
      name: self.name
    }
    json
  end

end