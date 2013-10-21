# -*- coding: utf-8 -*-
class ProjectInvite

  include Mongoid::Document

  field :invitor_organisation_uri, type: String
  field :invited_organisation_uri, type: String
  field :project_uri, type: String

  field :personalised_message, type: String
  belongs_to :invited_by_user, class_name: 'User'
  
  field :open, type: Boolean, default: true
  field :accepted, type: Boolean # nil until decision made.

  attr_accessor :natures

  def project_resource
    Project.find(self.project_uri)
  end

  def invitor_organisation_resource
    Organisation.find(self.invitor_organisation_uri)
  end

  def invited_organisation_resource
    Organisation.find(self.invited_organisation_uri)
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
