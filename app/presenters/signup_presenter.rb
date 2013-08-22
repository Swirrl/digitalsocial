class SignupPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :name, :organisation, :user, :organisation_membership,
    :lat, :lng, :street_address, :locality, :region, :country, :postal_code # location related fields

  attr_accessible :name, :lat, :lng, :street_address, :locality, :region, :country, :postal_code

  validates :name, :lat, :lng,  :street_address, :locality, :country, presence: true

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

  def address
    return @address unless @address.nil?

    @address = Address.new
    @address.street_address = self.street_address
    @address.locality = self.locality
    @address.region = self.region
    @address.country = self.country
    @address.postal_code = self.postal_code

    @address
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

    if (self.address.save(transaction: transaction) &&
      self.site.save(transaction: transaction) &&
      self.organisation.save(transaction: transaction)
    )
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

  def organisation_guid
    self.organisation.guid
  end

  def persisted?
    false
  end

end