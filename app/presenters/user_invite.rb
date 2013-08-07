class UserInvite

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :user_first_name, :user_email, :sender

  validates :user_first_name, :user_email, presence: true
  validate :user_is_not_already_member_of_organisation

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def request
    @request ||= Request.new do |r|
      r.requestable  = self.sender.organisation_resource
      r.sender       = self.sender
      r.receiver     = self.organisation_membership
      r.request_type = 'organisation_invite'
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
      om.organisation_uri = self.sender.organisation_resource.uri.to_s
      om.user             = self.user
      om.owner            = false
    end
  end

  def organisation
    self.sender.organisation_resource
  end

  def save
    return false if invalid?

    self.user.save
    self.organisation_membership.save
    self.request.save

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