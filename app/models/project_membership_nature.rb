class ProjectMembershipNature

  include Tripod::Resource

  rdf_type 'http://example.com/project_membership_nature'
  graph_uri 'http://example.com/dsi_data'

  field :label, 'http://example.com/label'

   # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || "http://example.com/project_membership_nature/#{Guid.new}")
  end

  def self.lead
    self.where("?uri <http://example.com/label> 'Lead'")
  end

end