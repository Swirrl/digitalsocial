class ProjectRequest

  include Mongoid::Document

  field :requestor_organisation_uri, type: String
  field :project_uri, type: String
  field :open, type: Boolean, default: true
  field :accepted, type: Boolean # nil until decision made.

  attr_accessor :natures

  def project_resource
    Project.find(self.project_uri)
  end

  def requestor_organisation_resource
    Organisation.find(self.requestor_organisation_uri)
  end

  def accept!
    return false unless natures.reject(&:blank?).any?

    add_requestor_to_project
    set_accepted

    self.save
  end

  def reject!
   set_rejected

   self.save
  end

  private

  def add_requestor_to_project
    project_resource.add_organisation(requestor_organisation_resource, natures)
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