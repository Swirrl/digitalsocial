class Organisation

  include Tripod::Resource
  include ConceptFields

  rdf_type 'http://www.w3.org/ns/org#Organization'
  graph_uri Digitalsocial::DATA_GRAPH

  field :name, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :primary_site, 'http://www.w3.org/ns/org#hasPrimarySite', is_uri: true

  field :no_of_staff, 'http://data.digitalsocial.eu/def/ontology/numberOfFTEStaff', datatype: RDF::XSD.integer
  field :twitter, 'http://data.digitalsocial.eu/def/ontology/twitterAccount', is_uri: true # this should be the full URL http://twitter.com/blah
  field :webpage, 'http://xmlns.com/foaf/0.1/page', is_uri: true

  concept_field :organisation_type, 'http://data.digitalsocial.eu/def/ontology/organizationType', Concepts::OrganisationType
  concept_field :fte_range, 'http://data.digitalsocial.eu/def/ontology/numberOfFTEStaff', Concepts::FTERange

  validates :name, presence: true

  attr_accessor :invited_users, :invites_to_send

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

  def address_str
    self.primary_site_resource.address_resource.to_s
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

  def is_member_of_project?(project)
    project_memberships_for_project(project).count > 0
  end

  def can_edit_project?(project)
    is_member_of_project?(project)
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

  # People who've requested to join this org
  def respondable_user_requests
    UserRequest.where(responded_to: false, is_invite: false, requestable_id: self.uri.to_s)
  end

  def has_respondables?
    respondables.any?
  end

  def respondables
    pending_project_invites + 
      pending_project_requests_by_others +
      respondable_user_requests
  end

  def as_json(options = nil)
    json = {
      name: self.name,
      guid: self.guid,
      image_url: self.image_url,
      uri: self.uri.to_s,
      address: self.address_str
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
    @invited_users   = ary
    @invites_to_send = []

    ary.each do |n, u|
      if u[:first_name].present? || u[:email].present?
        uip = UserInvitePresenter.new
        uip.user_first_name = u[:first_name]
        uip.user_email      = u[:email]
        uip.organisation    = self

        if uip.invalid?
          @invited_users[n][:error] = uip.errors.full_messages.first
        else
          @invites_to_send << uip
        end
      end
    end
  end

  def can_send_user_invites?
    @invited_users.each { |_, u| return false if u[:error].present? }
    true
  end

  def send_user_invites
    @invites_to_send.each(&:save)
  end

  def build_user_invites
    @invited_users = {}
    50.times { |n| @invited_users[n.to_s] ||= {} }
  end

end