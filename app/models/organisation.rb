class Organisation

  include Mongoid::Document
  include Mongoid::Slug

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable, :token_authenticatable

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

  field :name,         type: String
  field :contact_name, type: String
  field :lat,          type: String
  field :lng,          type: String
  
  slug :name

  validates :name, :contact_name, :email, :lat, :lng, presence: true

  after_create :create_tripod_organisation
  after_save :update_tripod_organisation

  def tripod_organisation
    TripodOrganisation.find(tripod_organisation_uri)
  end

  def tripod_organisation_uri
    "http://example.com/organisations/#{slug}"
  end

  def tripod_organisation_attributes
    {
      name: name,
      lat: lat,
      lng: lng
    }
  end

  private

  def create_tripod_organisation
    to = TripodOrganisation.new(tripod_organisation_uri)
    to.save
  end

  def update_tripod_organisation
    tripod_organisation.update_attributes(tripod_organisation_attributes)
  end

end