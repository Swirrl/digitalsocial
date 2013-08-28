class UserInvitePresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :user_first_name, :user_email, :organisation

  validates :user_first_name, :user_email, presence: true
  validates :user_email, format: { with: Devise.email_regexp }
  validate :user_is_not_already_member_of_organisation

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def user
    @user ||= User.where(email: self.user_email).first || User.new do |u|
      u.first_name = self.user_first_name
      u.email      = self.user_email
      u.password   = rand(36**16).to_s(36) # Temporary random password
    end
  end

  def organisation_membership
    @organisation_membership ||= OrganisationMembership.new do |om|
      om.organisation_uri = self.organisation.uri.to_s
      om.user             = self.user
      om.owner            = false
    end
  end

  def save
    return false if invalid?

    self.user.reset_password_token   = User.reset_password_token
    self.user.reset_password_sent_at = Time.now

    self.user.save
    self.organisation_membership.save

    RequestMailer.organisation_invite(user, organisation).deliver

    true
  rescue => e
    false
  end

  def persisted?
    false
  end

  private

  def user_is_not_already_member_of_organisation
    if self.user.organisation_memberships.where(organisation_uri: self.organisation.uri.to_s).count > 0
      errors.add(:user_email, 'already a member of this organisation')
    end
  end

end