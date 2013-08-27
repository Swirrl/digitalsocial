class ProjectInvitePresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  # mass assignable
  attr_accessible :invited_organisation_name,
    :user_first_name,
    :user_email

  attr_accessor :invitor_organisation_uri,
    :invited_organisation_uri,

    # for making new org
    :invited_organisation_name,
    :user_first_name,
    :user_email,

    :project_uri


  validates :invited_organisation_name, :user_first_name, :user_email, presence: { if: :new_organisation? }
  validates :user_email, format: { with: Devise.email_regexp, if: :new_organisation? }

  validate :organisation_is_not_already_member_of_project
  validate :invite_doesnt_already_exist

  validates :project_uri, presence: true

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def new_organisation?
    # if org uri of invited org not set, must be a new org.
    !self.invited_organisation_uri
  end

  def invited_organisation
    return @organisation if @organisation

    if new_organisation?
      @organisation = Organisation.new
      @organisation.name = self.invited_organisation_name
    else
      @organisation = Organisation.find(self.invited_organisation_uri)
    end

    @organisation
  end

  def user
    return @user if @user

    if new_organisation?
      @user = User.where(email: self.user_email).first

      unless @user
        @user ||= User.new do |user|
          user.first_name = self.user_first_name
          user.email      = self.user_email
          user.password   = rand(36**16).to_s(36) # Temporary random password
        end
      end

      @user
    else
      return nil
    end
  end

  def organisation_membership
    return @organisation_membership if @organisation_membership

    if new_organisation?
      @organisation_membership ||= OrganisationMembership.new do |om|
        om.user             = self.user
        om.organisation_uri = self.invited_organisation.uri.to_s
        om.owner            = true
      end
    else
      @organisation_membership = nil
    end

    @organisation_membership
  end

  def project
    @project ||= Project.find(self.project_uri)
  end

  def project_invite
    @project_invite ||= ProjectInvite.new do |i|
      i.invitor_organisation_uri  = self.invitor_organisation_uri
      i.invited_organisation_uri  = self.invited_organisation_uri
      i.project_uri = self.project_uri
    end
  end

  def save
    if new_organisation?
      save_for_new_organisation
    else
      save_for_existing_organisation
    end
  end

  def persisted?
    false
  end

  private

  def existing_project_membership?
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s

    ProjectMembership
      .where("?uri <#{project_membership_org_predicate}> <#{self.invited_organisation_uri}>")
      .where("?uri <#{project_membership_project_predicate}> <#{self.project_uri}>")
      .count > 0
  end

  def open_invite?
    ProjectInvite.where(
      project_uri: self.project_uri,
      invited_organisation_uri: self.invited_organisation_uri,
      open: true
    ).count > 0
  end

  def save_for_new_organisation
    if invalid?
      Rails.logger.debug( self.errors.inspect )
      return false
    end

    transaction = Tripod::Persistence::Transaction.new

    if self.invited_organisation.save(transaction: transaction)
      transaction.commit

      self.user.save unless self.user.persisted?
      self.organisation_membership.save
      self.project_invite.save

      RequestMailer.project_new_organisation_invite(self, user).deliver
    else
      transaction.abort
    end

    true
  rescue => e
    Rails.logger.debug( e.inspect )
    false
  end

  def save_for_existing_organisation
    if invalid?
      Rails.logger.debug( self.errors.inspect )
      return false
    end

    self.project_invite.save
  rescue => e
    Rails.logger.debug( e.inspect )
    false
  end

  def organisation_is_not_already_member_of_project
    errors.add(:project_uri, "Your organisation is already a member of this project") if existing_project_membership?
  end

  def invite_doesnt_already_exist
    errors.add(:project_uri, "Someone has invited this organisation to this project") if open_invite?
  end

end