class UserRequest

  include Mongoid::Document

  belongs_to :user

  field :organisation_uri, type: String
  field :open, type: Boolean, default: true
  field :accepted, type: Boolean # nil until decision made.

  attr_accessor :natures

  def organisation_resource
    Organisation.find(self.organisation_uri)
  end

  def accept!
    add_user_to_organisation
    set_accepted
    send_user_request_acceptance

    self.save
  end

  def reject!
   set_rejected

   self.save
  end

  private

  def add_user_to_organisation
    organisation_resource.add_user(user)
  end

  def set_accepted
    self.open = false
    self.accepted = true
  end

  def set_rejected
    self.open = false
    self.accepted = false
  end

  def send_user_request_acceptance
    RequestMailer.user_request_acceptance(self, user).deliver
  end

end