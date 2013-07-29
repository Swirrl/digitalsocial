class Project

  include Tripod::Resource

  rdf_type 'http://example.com/project'
  graph_uri 'http://example.com/projects'

  field :label, 'http://example.com/label'
  field :webpage, 'http://example.com/webpage'
  field :tags, 'http://example.com/tag', multivalued: true
  field :duration, 'http://example.com/time_interval'

  attr_accessor :tags_list, :start_date, :end_date#, :creator_role

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/project/#{Guid.new}")
    self.rdf_type ||= Project.rdf_type
  end

  # Temporary
  def tags_list=(list)
    self.tags = list.split(", ")
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

  def create_lead_membership!(organisation)
    lead_membership = ProjectMembership.new
    lead_membership.organisation = organisation.uri.to_s
    lead_membership.project      = self.uri.to_s
    lead_membership.save
  end

end