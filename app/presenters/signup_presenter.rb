class SignupPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :name, :lat, :lng, :organisation, :user, :organisation_membership
  attr_accessible :name, :lat, :lng

  validates :name, :lat, :lng, presence: true

  # def self.name
  #   User.name
  # end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def site
    return @site unless @site.nil?

    @site = Site.new
    @site.lat = self.lat
    @site.lng = self.lng
    @site
  end

  def organisation
    return @organisation unless @organisation.nil?

    @organisation = Organisation.new
    @organisation.name         = self.name
    @organisation.primary_site = self.site.uri
    @organisation
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

      self.organisation_membership.save
    else
      transaction.abort
    end

    true
  rescue => e
    Rails.logger.debug e
    false
  end

  def persisted?
    false
  end

end