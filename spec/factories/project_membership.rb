FactoryGirl.define do
  factory :project_membership do
    organisation { FactoryGirl.create(:organisation).uri.to_s }
    project      { FactoryGirl.create(:project).uri.to_s }
    nature       { ProjectMembershipNature.all.first.uri }
  end
end
