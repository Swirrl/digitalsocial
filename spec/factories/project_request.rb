FactoryGirl.define do
  factory :project_request do
    requestor_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    project_uri { FactoryGirl.create(:project).uri.to_s }
    natures { [Concepts::ProjectMembershipNature.all.first.uri] }
    open true
    accepted nil
  end
end
