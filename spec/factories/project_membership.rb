FactoryGirl.define do
  factory :project_membership do
    ignore do
      use_existing_organisations false
    end

    organisation do
      if use_existing_organisations
        Organisation.all.resources[rand(Organisation.count)].uri.to_s
      else
        FactoryGirl.create(:organisation).uri.to_s
      end
    end
    
    project      { FactoryGirl.create(:project).uri.to_s }
    nature       { Concepts::ProjectMembershipNature.all.first.uri }
  end
end
