class ProjectRequestPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :project_uri, :nature_uri, :organisation

  validates :project_uri, :nature_uri, :organisation, presence: true
  validate :organisation_is_not_already_member_of_project

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def project
    @project ||= Project.find(self.project_uri)
  end

  def creator_organisation
    Organisation.find(self.project.creator.to_s)
  end

  def request
    @request ||= ProjectRequest.new do |r|
      r.requestable  = self.project
      r.requestor    = self.organisation
      r.project_membership_nature_uri = self.nature_uri
    end
  end

  def save
    return false if invalid?

    self.request.save

    true
  rescue => e
    Rails.logger.debug e
    false
  end

  def save!
    self.save
  end

  def persisted?
    false
  end

  def existing_project_membership?
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s

    ProjectMembership
      .where("?uri <#{project_membership_org_predicate}> <#{self.organisation.uri}>")
      .where("?uri <#{project_membership_project_predicate}> <#{self.project_uri}>")
      .count > 0
  end

  private

  def organisation_is_not_already_member_of_project
    errors.add(:project_uri, "already a member of this project") if self.organisation.present? && existing_project_membership?
  end

end