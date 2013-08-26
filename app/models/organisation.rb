class Organisation

  include Tripod::Resource
  include ConceptFields

  rdf_type 'http://www.w3.org/ns/org#Organisation'
  graph_uri Digitalsocial::DATA_GRAPH

  field :name, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :primary_site, 'http://www.w3.org/ns/org#hasPrimarySite', is_uri: true

  field :no_of_staff, 'http://data.digitalsocial.eu/def/ontology/numberOfFTEStaff', datatype: RDF::XSD.integer
  field :twitter, 'http://data.digitalsocial.eu/def/ontology/twitterAccount', is_uri: true # this should be the full URL http://twitter.com/blah
  field :webpage, 'http://xmlns.com/foaf/0.1/page', is_uri: true

  concept_field :organisation_type, 'http://data.digitalsocial.eu/def/ontology/organizationType', Concepts::OrganisationType
  concept_field :fte_range, 'http://data.digitalsocial.eu/def/ontology/numberOfFTEStaff', Concepts::FTERange

  validates :name, presence: true

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/organization/#{Guid.new}")
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def to_param
    guid
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

  def project_memberships_for_project(project)
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    ProjectMembership
      .where("?uri <#{project_membership_org_predicate}> <#{self.uri}>")
      .where("?uri <#{project_membership_project_predicate}> <#{project.uri}>")
  end

  # projects I've been invited to
  def pending_project_invites
    ProjectInvite.where(invited_organisation_uri: self.uri, open: true)
  end

  # projects I've requested to join
  def pending_project_requests_by_self
    ProjectRequest.where(requestor_organisation_uri: self.uri, open: true)
  end

  # Our projects that others have requested to join
  def pending_project_requests_by_others
    ProjectRequest.where(open: true).in(project_uri: project_resource_uris)
  end


  # # Pending project invites for this organisation that can be responded to
  # def respondable_project_invites
  #   ProjectRequest.where(requestor_type: 'Organisation', requestor_id: self.uri.to_s, responded_to: false, is_invite: true).all
  # end

  # # Pending project requests made by another organisation to join one of this organisation's projects
  # def respondable_project_requests
  #   ProjectRequest.where(requestable_type: 'Project', responded_to: false, is_invite: false).in(requestable_id: project_resource_uris).all
  # end

  # # Pending requests by this org to join a project.
  # def pending_project_requests
  #   ProjectRequest.where(requestable_type: 'Project', requestor_id: self.uri.to_s, responded_to: false, is_invite: false).all
  # end

  # People who've requested to join this org
  def respondable_user_requests
    UserRequest.where(responded_to: false, is_invite: false, requestable_id: self.uri.to_s)
  end

  def has_respondables?
    pending_project_invites.any? ||
      pending_project_requests_by_others.any? ||
      respondable_user_requests
  end

  def can_edit_project?(project)
    true # everyone can edit project for now.
  end

  def as_json(options = nil)
    json = {
      name: self.name,
      guid: self.guid,
      image_url: self.image_url
    }
    json
  end

  def image_url
    # TODO allow logo upload
    "/assets/asteroids/#{rand(5)+1}_70x70.png"
  end

  def self.search_by_name(search)
    name_predicate = self.fields[:name].predicate.to_s
    self.where("?uri <#{name_predicate}> ?name").where("FILTER regex(?name, \"#{search}\", \"i\")").resources
  end

  def twitter_username=(username)
    username.strip!
    username.gsub!(/^@/, "")
    self.twitter = "http://twitter.com/#{username}"
  end

  def twitter_username
    username = self.twitter.to_s.split("/")[3] # Do cleaner way
    "@#{username}" if username.present?
  end

  def users
    OrganisationMembership.all.select{ |om| om.organisation_uri == self.uri  }.map { |om| User.find(om.user_id) rescue nil }.reject { |u| u.nil? }
  end

  def invited_users=(ary)
    ary.reject! { |_, u| u[:first_name].blank? || u[:email].blank? }

    ary.each do |_, u|
      uip = UserInvitePresenter.new
      uip.user_first_name = u[:first_name]
      uip.user_email      = u[:email]
      uip.organisation    = self
      uip.save
    end

  end

end