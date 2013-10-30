class ProjectInvitePresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  # mass assignable
  attr_accessible :invited_organisation_name,
    :user_first_name,
    :user_email,
    :personalised_message,
    :project_uri,
    :invited_organisation_uri,
    :invitor_organisation_uri

  attr_accessor :invitor_organisation_uri,
    :invited_organisation_uri,
    #:invited_organisation_id,
    :invited_by_user,
    # for making new org
    :invited_organisation_name,
    :user_first_name,
    :user_email,
  
    :project_uri,
    :personalised_message


  validates :invited_organisation_name, :user_first_name, :user_email, presence: { if: :new_organisation?}
  validates :user_email, format: { with: Devise.email_regexp, if: :new_organisation? }

  validate :organisation_is_not_already_member_of_project
  validate :invite_doesnt_already_exist

  validates :project_uri, presence: true

  def initialize(attrs={})
    self.attributes = attrs
  end
      
  def new_organisation?
    org_id = Organisation.uri_to_slug(self.invited_organisation_uri)
    @is_new_organisation = org_id.blank?
  end

  def invitor_organisation
    return @invitor_organisation if @invitor_organisation
    @invitor_organisation = Organisation.find(self.invitor_organisation_uri)
    @invitor_organisation
  end

  def invited_organisation
    return @organisation if @organisation

    if new_organisation?
      @organisation = Organisation.new
      @organisation.name = self.invited_organisation_name
#     @invited_organisation_uri = @organisation.uri
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
          user.first_name = self.user_first_name.strip
          user.email      = self.user_email.strip
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
      i.invited_organisation_uri  = self.invited_organisation.uri # the invited_organisation method will instatiate the org for new ones.
      i.invited_by_user = self.invited_by_user
      i.project_uri = self.project_uri
      i.personalised_message = self.personalised_message
    end
  end

  def save
    if new_organisation?
      if save_for_new_organisation
        RequestMailer.project_new_organisation_invite(self, user).deliver
      end
    else
      save_for_existing_organisation
    end
  end

  def persisted?
    false
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
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
      invited_organisation_uri: self.invited_organisation.uri,
      open: true
    ).count > 0
  end

  def save_for_new_organisation
    if invalid?
      Rails.logger.debug( self.errors.inspect )
      return false
    end

    begin
      transaction = Tripod::Persistence::Transaction.new

      if self.invited_organisation.save(transaction: transaction)
        # so the user needs a password reset.
        self.user.reset_password_token   = User.reset_password_token
        self.user.reset_password_sent_at = Time.now
        
        self.user.save(transaction: transaction) unless self.user.persisted?
        self.organisation_membership.save(transaction: transaction)
        self.project_invite.save(transaction: transaction)
        transaction.commit
      else
        transaction.abort
      end
      
      true
    rescue => e
      Rails.logger.debug( e.inspect )
      Rails.logger.debug( e.backtrace.join("\n") )
      false
    end
  end

  def save_for_existing_organisation
    if invalid?
      Rails.logger.debug( self.errors.inspect )
      return false
    end

    self.project_invite.save
  rescue => e
    Rails.logger.debug( e.inspect )
    Rails.logger.debug( e.backtrace.join("\n") )
    false
  end

  def organisation_is_not_already_member_of_project
    errors.add(:project_uri, "Your organisation is already a member of this project") if existing_project_membership?
  end

  def invite_doesnt_already_exist
    errors.add(:project_uri, "Someone has invited this organisation to this project") if open_invite?
  end

end
