require 'spec_helper'

feature 'New project' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit new_project_path
  end

  scenario 'Filling in new project step successfully' do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    choose 'Research Project'
    check 'We are the sole funder'
    check 'We are the delivery lead'
    select 'January 2011', from: 'Activity start date'
    select 'Ongoing', from: 'Activity end date'
    uncheck 'Open Networks'
    check 'Open Hardware'
    fill_in 'Areas of Society Impacted', with: 'Finance'
    fill_in 'Technology Method', with: 'Peer Support'

    click_button 'Create'

    page.current_path.should == "/user"
  end

  scenario 'Filling in new project step unsuccessfully' do
    click_button 'Create'

    page.current_path.should_not == "/user"
  end

  scenario 'Show other field if other radio button selected', js: true do
    first('.project_activity_type_label_other').should_not be_present
    choose 'Other'
    first('.project_activity_type_label_other').should be_present
  end

  scenario 'Suggest to join an existing project', js: true do
    FactoryGirl.create(:project, name: 'A brilliant project')

    fill_in 'Name', with: 'brill'

    page.should have_content 'A brilliant project'
    page.should have_link 'Request to join'
  end

  scenario 'Fill in with specifying other field', js: true do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    check 'We are the sole funder'
    check 'We are the delivery lead'

    choose 'Other'
    fill_in 'project_activity_type_label_other', with: 'Something else'
    click_button 'Create'

    page.current_path.should == "/user"
  end

  scenario 'Activity type radio buttons should be validated' do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    check 'We are the sole funder'
    check 'We are the delivery lead'

    click_button 'Create'

    page.current_path.should_not == "/user"
    page.should have_css('.error')
  end

  scenario 'Nature checkboxes should be validated' do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    choose 'Research Project'

    click_button 'Create'
    
    page.current_path.should_not == "/user"
    page.should have_css('.project_organisation_natures .error')
  end
  
end