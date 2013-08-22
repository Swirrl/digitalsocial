class UserRequest < Request

  field :user_first_name, type: String
  field :user_email, type: String

  validates :user_first_name, :user_email, :requestable, presence: true
  validate :email_does_not_already_belong_to_organisation, if: :new_record?
  validate :duplicate_request_does_not_already_exist, if: :new_record?

  def accept!
    invite_user!
  end

  def invite_user!
    user_invite = build_user_invite

    if user_invite.save
      self.responded_to = true
      self.save

      true
    else
      false
    end
  end

  def self.build_user_request(user, org)
    user_request = UserRequest.new
    user_request.user_email = user.email
    user_request.user_first_name = user.first_name
    user_request.is_invite = false
    user_request.requestor = user
    user_request.requestable = org
    user_request
  end

  def build_user_invite
    user_invite = UserInvitePresenter.new
    user_invite.user_first_name = self.user_first_name
    user_invite.user_email      = self.user_email
    user_invite.organisation    = self.requestable
    user_invite
  end

  private

  def email_does_not_already_belong_to_organisation
    errors.add(:user_email, 'This email already belongs to the organisation') if email_already_belongs_to_organisation?
  end

  def email_already_belongs_to_organisation?
    user = User.where(email: user_email).first

    user.present? &&
      OrganisationMembership.where(user_id: user.id, organisation_uri: requestable_id).count > 0
  end

  def duplicate_request_does_not_already_exist
    errors.add(:user_email, 'A request already exists for this email address') if duplicate_request_exists?
  end

  def duplicate_request_exists?
    UserRequest.where(responded_to: false, user_email: user_email, requestable_id: requestable_id).count > 0
  end

end