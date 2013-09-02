require 'spec_helper'

feature 'Edit organisation wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit organisations_build_edit_organisation_path
  end

  scenario 'Filling in edit organisation step successfully' do
    fill_in 'Website', with: 'http://test.com'
    fill_in 'Twitter', with: '@test'
    choose '0-5'
    choose 'Business'
    
    click_button 'Next step'

    page.current_url.should include("organisations/build/new_project")
  end

  scenario 'Filling in edit organisation step successfully with no details' do
    click_button 'Next step'

    page.current_url.should include("organisations/build/new_project")
  end

  scenario 'Skipping the edit organisation step' do
    page.should have_link('Skip', href: organisations_build_new_project_path)
  end
  
end