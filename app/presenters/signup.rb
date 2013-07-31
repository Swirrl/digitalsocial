require 'active_model/model'

class Signup

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :user, :first_name, :email, :password, :organisation_name,
                :organisation_lat, :organisation_lng, :organisation, :user
  attr_accessible :first_name, :email, :password, :organisation_name,
                  :organisation_lat, :organisation_lng

  validates :first_name, :email, :password, :organisation_name,
            :organisation_lat, :organisation_lng, presence: true
  validates :email, format: { with: Devise.email_regexp }
  validate :user_email_must_be_unique

  def self.name
    User.name
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def site
    return @site unless @site.nil?

    @site = Site.new("http://example.com/site/#{Guid.new}")
    @site.lat = self.organisation_lat
    @site.lng = self.organisation_lng
    @site
  end

  def organisation
    return @organisation unless @organisation.nil?

    @organisation = Organisation.new("http://example.com/organisation/#{Guid.new}")
    @organisation.name         = self.organisation_name
    @organisation.primary_site = self.site.uri
    @organisation
  end

  def user
    @user ||= User.new do |user|
      user.first_name = self.first_name
      user.email      = self.email
      user.password   = self.password
    end
  end

  def organisation_membership
    @organisation_membership ||= OrganisationMembership.new do |om|
      om.user             = self.user
      om.organisation_uri = self.organisation.uri.to_s
      om.owner            = true
    end
  end

  def save
    return false if invalid?
    
    transaction = Tripod::Persistence::Transaction.new
    if self.site.save(transaction: transaction) && self.organisation.save(transaction: transaction)
      transaction.commit
      
      self.user.save
      self.organisation_membership.save
    else
      transaction.abort
    end

    true
  rescue
    false
  end

  def persisted?  
    false  
  end

  private

  def user_email_must_be_unique
    duplicate_user = User.where(email: self.email).first

    if duplicate_user.present? && duplicate_user != self.user
      errors.add(:email, 'has already been taken')
    end
  end

end