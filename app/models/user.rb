class User

  include Mongoid::Document

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable, :token_authenticatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Token authenticatable
  field :authentication_token, type: String

  field :first_name, type: String
  field :receive_notifications, type: Boolean, default: true

  has_many :organisation_memberships
  has_many :user_requests

  validates :first_name, :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: Devise.email_regexp }

  before_save :ensure_authentication_token

  def organisation_resources
    organisation_memberships.collect(&:organisation_resource)
  end

  def send_request_digest(organisation)
    RequestMailer.request_digest(self, organisation).deliver
  end

  # requests by this user to join another org
  def pending_join_org_requests
    user_requests.where(open: true)
  end

  # invitest for this user to join another org
  def pending_join_org_invites
    UserRequest.where(responded_to: false, is_invite: true, requestor_id: self.id)
  end

  # Only send digest to users who have signed in
  def self.send_request_digests
    User.where(receive_notifications: true).gt(sign_in_count: 0).all.each do |user|
      user.organisation_resources.each do |organisation|
        user.send_request_digest(organisation) if organisation.has_respondables?
      end
    end
  end

  # Users who have not signed in at all
  def self.send_unconfirmed_user_reminders
    User.where(receive_notifications: true).where(sign_in_count: 0).all.each do |user|
      RequestMailer.unconfirmed_user_reminder(user).deliver
    end
  end

  def self.send_projectless_user_reminders
    User.where(receive_notifications: true).all.each do |user|
      user.organisation_resources.each do |organisation|
        RequestMailer.projectless_user_reminder(user, organisation).deliver unless organisation.any_projects?
      end
    end
  end

  def self.create_with_organisation_membership_from_project_invite project_invite
    user = User.create :email => project_invite.invited_email,
                       :first_name => project_invite.invited_user_name,
                       :password => User.random_password,
                       :reset_password_token => User.reset_password_token,
                       :reset_password_sent_at => Time.now

    if user.persisted?
      invited_organisation_uri = project_invite.invited_organisation_uri
      membership = OrganisationMembership.create user: user, organisation_uri: invited_organisation_uri.to_s

      unless membership.persisted?
        raise "Could not persist membership for a new user for an unknown reason. #{membership.errors.inspect}"
      end
      
      project_invite.invited_user = user
      unless project_invite.save
        user.destroy
        membership.destroy
        raise "Could not persist changes to project_invite #{membership.errors.inspect}"
      end
    end

    user
  end

  def self.random_password
    rand(36**16).to_s(36) # Temporary random password
  end
end
