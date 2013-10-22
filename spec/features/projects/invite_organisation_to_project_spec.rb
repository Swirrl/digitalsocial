require 'spec_helper'

feature 'Invite a new Organisation to Join Project' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:project) { FactoryGirl.create(:project, scoped_organisation: organisation) }

  background do
    login_as user, scope: :user
    visit invite_project_path(project)
  end

  scenario 'supplying email address' do
    fill_in 'Organisation Name', with: "Swirrl"
    fill_in 'User first name', with: "Ric"
    fill_in 'User email', with: "ric@swirrl.com"
    fill_in 'Personalised message', with: "We worked on linked data together"
    click_button 'Invite organisation'

    page.current_path.should == dashboard_projects_path
  end
  
end

feature 'Invite another Organisation to Join Project' do
  
  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:another_organisation) { FactoryGirl.create(:organisation_with_users) }
  let(:project) { FactoryGirl.create(:project, scoped_organisation: organisation) }

  background do
    login_as user, scope: :user
    visit invite_project_path(project)
  end

  scenario 'supplying email address', js: true do
    partial_name = another_organisation.name.slice(0, 3)
    fill_in 'Organisation Name', with: partial_name
    # within(".suggestions") do
    #   click_link 'Invite', match: :first
    # end
    
    hidden_field = find(:xpath, "//input[@id='invited-organisation-id']")
    hidden_field.set(another_organisation.guid)

    find("#invited-organisation-id").set(another_organisation.guid)

    page.save_screenshot '/tmp/foo.png', :full => true
    fill_in 'Personalised message', with: "Hi, it's me!"
    
    page.save_screenshot '/tmp/foo2.png', :full => true
    click_button 'Invite organisation'
    page.current_path.should == dashboard_projects_path
    page.save_screenshot '/tmp/foo3.png', :full => true
  end

end
