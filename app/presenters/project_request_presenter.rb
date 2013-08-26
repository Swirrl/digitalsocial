class ProjectRequestPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor:project_uri, # project being requested to join
    :nature_uris, # nature of relationship

    :user_organisation_uri, # the details of the contact.
    :user_first_name,
    :user_email,

    :organisation # the organisation making the reuqest

  validates :project_uri, :nature_uris, :organisation, presence: true
  validate :organisation_is_not_already_member_of_project

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def project
    @project ||= Project.find(self.project_uri.to_s)
  end

  def user_organisation
    Organisation.find(self.user_organisation_uri)
  end

  def project_request
    @project_request ||= ProjectRequest.new do |r|

      Rails.logger.debug " project request"
      Rails.logger.debug self.project_uri
      Rails.logger.debug self.project
      Rails.logger.debug self.organisation

      r.requestable  = self.project
      r.requestor    = self.organisation
      r.project_membership_nature_uris = self.nature_uris.reject {|u| u.blank?}
    end
  end

  def user_request
    @user_request ||= UserRequest.new do |r|
      r.requestable     = self.user_organisation
      r.user_first_name = self.user_first_name
      r.user_email      = self.user_email
    end
  end

  def save

    if invalid?
      Rails.logger.debug "invalid"
      return false
    end

    self.project_request.save

    # if self.user_organisation # if they supplied an organisation
    #   self.user_request.save if self.user_request.valid?
    # end

    true
  rescue => e
    Rails.logger.debug "save failed"
    Rails.logger.debug e.inspect
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