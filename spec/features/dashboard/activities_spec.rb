require 'spec_helper'

feature 'Dashboard activities page' do

  background do
    login_as user, scope: :user
    visit dashboard_projects_path
  end

  context "with an organisation" do

    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
    let(:organisation) { user.organisation_resources.first }

    scenario 'Add a new project link' do
      page.should have_link('Add/join an activity', href: new_project_path)
    end

    context "with a project" do

      scenario 'Add a new project link' do
        FactoryGirl.create(:project, scoped_organisation: organisation)
        visit dashboard_projects_path
        page.should have_link('Add/join another activity', href: new_project_path)
      end

    end

  end
  
end