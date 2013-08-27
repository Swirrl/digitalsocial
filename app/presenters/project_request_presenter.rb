class ProjectRequestPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :requestor_organisation_uri,
    :project_uri

  validates :project_uri, :requestor_organisation_uri, presence: true

  validate :organisation_is_not_already_member_of_project,
    :no_existing_requests

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def project
    @project ||= Project.find(self.project_uri.to_s)
  end

  def requestor_organisation
    Organisation.find(self.requestor_organisation_uri)
  end

  def project_request
    @project_request ||= ProjectRequest.new do |r|
      r.project_uri  = self.project_uri
      r.requestor_organisation_uri = self.requestor_organisation_uri
    end
  end

  def save

    if invalid?
      Rails.logger.debug self.errors.inspect
      return false
    end

    self.project_request.save

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
      .where("?uri <#{project_membership_org_predicate}> <#{self.requestor_organisation_uri}>")
      .where("?uri <#{project_membership_project_predicate}> <#{self.project_uri}>")
      .count > 0
  end

  def existing_pending_request?
    ProjectRequest.where(
      project_uri: self.project_uri,
      requestor_organisation_uri: self.requestor_organisation_uri,
      open: true
    ).count > 0
  end

  private

  def organisation_is_not_already_member_of_project
    errors.add(:project_uri, "This organisation is already a member of this project") if existing_project_membership?
  end

  def no_existing_requests
    errors.add(:project_uri, "Your organisation has already requsted membership to this project") if existing_pending_request?
  end

end