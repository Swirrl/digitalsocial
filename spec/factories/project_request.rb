# attr_accessor :project_uri, :nature_uri, :sender, :organisation

# validates :project_uri, :nature_uri, presence: true
# validate :organisation_is_not_already_member_of_project

FactoryGirl.define do
  factory :project_request do
    organisation { FactoryGirl.create(:organisation) }
    project_uri  { FactoryGirl.create(:project).uri.to_s }
    nature_uri   { FactoryGirl.create(:project_membership_nature).uri.to_s }
    sender       { FactoryGirl.create(:organisation_membership) }
  end
end
