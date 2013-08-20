FactoryGirl.define do
  factory :project_request_presenter do
    organisation { FactoryGirl.create(:organisation) }
    project_uri  { FactoryGirl.create(:project).uri.to_s }
    nature_uri   { Concepts::ProjectMembershipNature.all.first.uri }
  end
end
