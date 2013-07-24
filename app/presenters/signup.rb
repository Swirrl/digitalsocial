require 'active_model/model'

class Signup

  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :user, :first_name, :email, :password
  attr_accessible :first_name, :email, :password

  validates :first_name, :email, :password, presence: true
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

  def user
    @user ||= User.new do |user|
      user.first_name = self.first_name
      user.email      = self.email
      user.password   = self.password
    end
  end

  def save
    return false if invalid?
    
    self.user.save!

    true
  rescue => e
    false
  end

  def persisted?  
    false  
  end

  private

  def user_email_must_be_unique
    errors.add(:email, 'has already been taken') if User.where(email: self.email).any?
  end

end