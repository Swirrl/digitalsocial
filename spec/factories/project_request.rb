FactoryGirl.define do
  factory :project_request do
    organisation { FactoryGirl.create(:organisation) }
    project_uri  { FactoryGirl.create(:project).uri.to_s }
    nature_uri   { FactoryGirl.create(:project_membership_nature).uri.to_s }
  end
end
