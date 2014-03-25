FactoryGirl.define do
  factory :project_request_presenter do
    requestor_organisation_uri { FactoryGirl.create(:organisation).uri.to_s }
    project_uri  { FactoryGirl.create(:project).uri.to_s }
  end
end
