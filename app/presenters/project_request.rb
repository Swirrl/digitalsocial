require 'active_model/model'

class ProjectRequest

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :project_uri, :nature_uri, :sender, :organisation

  # TODO validate project isn't already member of project

  validates :project_uri, :nature_uri, presence: true

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def project
    @project ||= Project.find(self.project_uri)
  end

  # Owner of the organisation that created the project
  def organisation_membership
    OrganisationMembership.owners.where(organisation_uri: self.project.creator.to_s).first
  end

  def request
    @request ||= Request.new do |r|
      r.requestable  = self.project
      r.sender       = self.sender
      r.receiver     = self.organisation_membership
      r.request_type = 'project_request'
      r.data         = { project_membership_nature_uri: self.nature_uri }
    end
  end

  def save
    return false if invalid?

    self.request.save

    true
  rescue => e
    false
  end

  def persisted?  
    false  
  end

end