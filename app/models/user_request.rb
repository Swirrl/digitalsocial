class UserRequest < Request

  field :user_first_name, type: String
  field :user_email, type: String

  validates :user_first_name, :user_email, presence: true
  validate :email_does_not_already_belong_to_organisation
  validate :duplicate_request_does_not_already_exist

  private

  def email_does_not_already_belong_to_organisation
    errors.add(:user_email, 'email already belongs to organisation') if email_already_belongs_to_organisation?
  end

  def email_already_belongs_to_organisation?
    user = User.where(email: user_email).first

    user.present? &&
      OrganisationMembership.where(user_id: user.id, organisation_uri: requestable_id).count > 0
  end

  def duplicate_request_does_not_already_exist
    errors.add(:user_email, 'request already exists for this email address') if duplicate_request_exists?
  end

  def duplicate_request_exists?
    UserRequest.where(responded_to: false, user_email: user_email, requestable_id: requestable_id).count > 0
  end

end