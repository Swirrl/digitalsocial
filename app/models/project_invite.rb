# -*- coding: utf-8 -*-
class ProjectInvite

  include Mongoid::Document

  field :invitor_organisation_uri, type: String
  field :invited_organisation_uri, type: String
  field :project_uri, type: String

  # These two fields should only be set on invites for existing
  # organisations.  They support the case where a you want to invite a
  # specific user that might be different to who is currently
  # administering the DSI profile.
  #
  # The invited_organisation administrator can then make a decision
  # about whether or not to invite the suggested member to their
  # organisation.  At which point this data will be copied into a new
  # User account.
  field :invited_email, type: String
  field :invited_user_name, type: String

  belongs_to :invited_user, class_name: 'User' # crappy name, this is the invitor_user

  field :personalised_message, type: String
  belongs_to :invited_by_user, class_name: 'User' # crappy name, this is the invitor_user
  
  field :open, type: Boolean, default: true
  field :accepted, type: Boolean # nil until decision made.
  field :handled_suggested_invite, type: Boolean, default: true
  
  attr_accessor :natures

  def invited_email= email
    write_attribute(:invited_email, email)
    # when setting the email mark invite as being unhandled
    write_attribute(:handled_suggested_invite, email.blank?)
  end
  
  def project_resource
    Project.find(self.project_uri)
  end

  def invitor_organisation_resource
    Organisation.find(self.invitor_organisation_uri)
  end

  def invited_organisation_resource
    Organisation.find(self.invited_organisation_uri)
  end

  # When suggested_invite? returns true this project_invite instance
  # also provides a suggestion that the receiving organisation should
  # invite another user into their organisation.
  def suggested_invite?
    !self.invited_email.blank?
  end
    
  def accept!
    return false unless natures.reject(&:blank?).any?

    add_invited_to_project
    set_accepted

    self.save
  end

  def reject!
    set_rejected

    self.save
  end

  def set_handled_suggested_user!
    self.handled_suggested_invite = true
    self.save
  end
  
  private

  def add_invited_to_project
    project_resource.add_organisation(invited_organisation_resource, natures)
  end

  def set_accepted
    self.open = false
    self.accepted = true
  end

  def set_rejected
    self.open = false
    self.accepted = false
  end
end
