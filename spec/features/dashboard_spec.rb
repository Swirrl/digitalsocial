require 'spec_helper'

feature 'Dashboard' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit user_path
  end

  scenario 'Add a new organisation link' do
    page.should have_link('Join another organisation', href: organisations_build_new_organisation_path)
  end

  scenario 'Add a new project link' do
    page.should have_link('Join an activity', href: new_project_path)
  end
  
end