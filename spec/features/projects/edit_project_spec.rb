require 'spec_helper'

feature 'Edit project' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:project) { FactoryGirl.create(:project, scoped_organisation: organisation) }

  background do
    login_as user, scope: :user
    visit edit_project_path(project)
  end

  scenario 'Updating the organisation successfully' do
    fill_in 'Name', with: 'A different name'
    fill_in 'Description', with: 'Lorem ispum etc'
    choose 'Event'
    uncheck 'Sole funder'
    check 'We are part of the advisory group'
    select 'January 2011', from: 'Activity start date'
    select 'Ongoing', from: 'Activity end date'
    uncheck 'Open Networks'
    check 'Open Hardware'
    fill_in 'Areas of Society Impacted', with: 'Finance'
    fill_in 'Technology Method', with: 'Peer Support'

    click_button 'Update'

    page.current_path.should == "/user"
  end

  scenario 'Updating the organisation unsuccessfully' do
    uncheck 'Sole funder'

    click_button 'Update'

    page.current_path.should_not == "/user"
  end

  scenario "Project suggestions not shown", js: true do
    FactoryGirl.create(:project, name: 'A brilliant project')

    fill_in 'Name', with: 'brill'

    page.should_not have_content 'A brilliant project'
    page.should_not have_link 'Request to join'
  end

  scenario "Not allowed to edit a project organisation is not a member of" do
    project2 = FactoryGirl.create(:project, name: "Forbidden project")
    visit edit_project_path(project2)

    page.current_path.should == "/user"
    page.should_not have_content "Forbidden project"
  end

end