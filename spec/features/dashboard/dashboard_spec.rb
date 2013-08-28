require 'spec_helper'

feature 'Dashboard' do

  background do
    login_as user, scope: :user
    visit user_path
  end

  context "with an organisation" do

    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
    let(:organisation) { user.organisation_resources.first }

    scenario 'Add a new organisation link' do
      page.should have_link('Add/join another organisation', href: organisations_build_new_organisation_path)
    end

    scenario 'Add a new project link' do
      page.should have_link('Add/join an activity', href: new_project_path)
    end

    context "with a project" do

      scenario 'Add a new project link' do
        FactoryGirl.create(:project, scoped_organisation: organisation)
        visit user_path
        page.should have_link('Add/join another activity', href: new_project_path)
      end

    end

  end

  context "without an organisation" do

    let(:user) { FactoryGirl.create(:user) }

    scenario 'Add a new organisation link' do
      page.should have_link('Add/join an organisation', href: organisations_build_new_organisation_path)
    end

  end
  
end