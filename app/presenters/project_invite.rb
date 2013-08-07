require 'active_model/model'

class ProjectInvite

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :organisation_name, :user_first_name, :user_email, :nature_uri,
    :organisation_uri, :project_uri, :new_organisation, :sender
  
  validates :organisation_name, :user_first_name, :user_email, presence: { if: :new_organisation? }
  validates :user_email, format: { with: Devise.email_regexp, if: :new_organisation? }
  validates :organisation_uri, presence: { unless: :new_organisation? }
  validate :user_email_must_be_unique, if: :new_organisation?
  # TODO validate project isn't already member of project

  validates :project_uri, :nature_uri, :sender, presence: true

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def new_organisation?
    self.new_organisation.present?
  end

  def request_type
    new_organisation? ? 'project_new_organisation_invite' : 'project_existing_organisation_invite'
  end

  def organisation
    return @organisation unless @organisation.nil?

    if self.organisation_uri.present?
      @organisation = Organisation.find(self.organisation_uri)
    else  
      @organisation = Organisation.new
      @organisation.name = self.organisation_name
    end

    @organisation
  end

  def user
    @user ||= User.new do |user|
      user.first_name = self.user_first_name
      user.email      = self.user_email
      user.password   = rand(36**16).to_s(36) # Temporary random password
    end
  end

  def organisation_membership
    return @organisation_membership unless @organisation_membership.nil?

    if new_organisation?
      @organisation_membership ||= OrganisationMembership.new do |om|
        om.user             = self.user
        om.organisation_uri = self.organisation.uri.to_s
        om.owner            = true
      end
    else
      @organisation_membership = OrganisationMembership.where(organisation_uri: self.organisation_uri, owner: true).first
    end
  end

  def project
    @project ||= Project.find(self.project_uri)
  end

  # def project_membership
  #   return @project_membership unless @project_membership.nil?

  #   @project_membership = ProjectMembership.new
  #   @project_membership.organisation = self.organisation.uri.to_s
  #   @project_membership.project      = self.project_uri
  #   @project_membership.nature       = self.nature_uri
  #   @project_membership
  # end

  def request
    @request ||= Request.new do |r|
      r.sender       = self.sender
      r.receiver     = self.organisation_membership
      r.requestable  = self.project
      r.request_type = self.request_type
      r.data         = { project_membership_nature_uri: self.nature_uri }
    end
  end

  def save
    if new_organisation?
      save_for_new_organisation
    else
      save_for_existing_organisation
    end
  end

  def save_for_new_organisation
    return false if invalid?

    transaction = Tripod::Persistence::Transaction.new
    if self.organisation.save(transaction: transaction)
      transaction.commit
      
      self.user.save
      self.organisation_membership.save
      self.request.save
    else
      transaction.abort
    end

    true
  rescue => e
    false
  end

  def save_for_existing_organisation
    return false if invalid?

    self.request.save

    true
  rescue => e
    false
  end

  def persisted?  
    false  
  end

  private

  def user_email_must_be_unique
    errors.add(:user_email, 'has already been taken') if User.where(email: self.user_email).any?
  end

end