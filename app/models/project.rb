class Project

  include Tripod::Resource
  include TagFields

  rdf_type 'http://xmlns.com/foaf/0.1/Project'
  graph_uri 'http://data.digitalsoclal.eu/graph/data'

  field :label, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :webpage, 'http://xmlns.com/foaf/0.1/page'

  field :duration, 'http://purl.org/NET/c4dm/event.owl#time'
  field :creator, 'http://data.digitalsocial.eu/def/ontology/recordedBy', is_uri: true

  # tag-like fields (tag_field method from TagFields module)
  tag_field :activity_type, 'http://data.digitalsocial.eu/def/ontology/activityType', ActivityType
  tag_field :areas_of_society, 'http://data.digitalsocial.eu/def/ontology/areaOfSociety', AreaOfSociety, multivalued: true
  tag_field :technology_focus, 'http://data.digitalsocial.eu/def/ontology/technologyFocus', TechnologyFocus, multivalued: true
  tag_field :technology_method, 'http://data.digitalsocial.eu/def/ontology/technologyMethod', TechnologyMethod, multivalued: true

  attr_accessor :start_date, :end_date, :creator_role

  validates :label, :webpage, presence: true
  validates :start_date, :end_date, :creator_role, presence: { if: :new_record? }

  #after_save :test

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://data.digitalsocial.eu/id/activity/#{Guid.new}")
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def to_param
    guid
  end

  def create_time_interval!
    new_time_interval = TimeInterval.new
    new_time_interval.start_date = start_date
    new_time_interval.end_date   = end_date
    new_time_interval.save

    self.duration = new_time_interval.uri.to_s
    save
  end

  def duration_resource
    TimeInterval.find(self.duration)
  end

  # def start_date
  #   duration_resource.start_date if duration.present?
  # end

  # def end_date
  #   duration_resource.end_date if duration.present?
  # end

  def creator_resource
    Organisation.find(self.creator)
  end

  def add_creator_membership!(organisation)
    creator_membership = ProjectMembership.new
    creator_membership.organisation = organisation.uri.to_s
    creator_membership.project      = self.uri.to_s
    creator_membership.nature       = self.creator_role
    creator_membership.save

    self.creator = organisation.uri
    self.save
  end

  def organisations
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    Organisation
      .where("?pm_uri <#{project_membership_project_predicate}> <#{self.uri}>")
      .where("?pm_uri <#{project_membership_org_predicate}> ?uri")
  end

  def organisation_resources
    organisations.resources
  end

  def any_organisations?
    organisations.count > 0
  end

  def invite_new_organisation!
    false
  end

end