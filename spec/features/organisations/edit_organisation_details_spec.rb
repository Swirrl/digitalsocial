require 'spec_helper'

feature 'Edit organisation details' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit edit_organisation_path(organisation)
  end

  scenario 'Updating the organisation successfully' do
    fill_in 'Name', with: 'A different name'
    fill_in 'Website', with: 'http://somethingelse.com'
    fill_in 'Twitter', with: '@somethingelse'
    choose '6-10'
    choose 'Social Enterprise Charity Or Foundation'
    attach_file 'Your Logo', "#{Rails.root}/test/example.png"
    
    click_button 'Update'

    page.current_path.should == edit_organisation_path(organisation.guid)
  end

  scenario 'Updating the organisation unsuccessfully' do
    fill_in 'Name', with: ''
    click_button 'Update'

    page.current_path.should_not == edit_organisation_path(organisation.guid)
  end

  scenario "Project suggestions not shown", js: true do
    FactoryGirl.create(:organisation, name: 'An amazing organisation')

    fill_in 'Name', with: 'amazin'

    page.should_not have_content 'An amazing organisation'
    page.should_not have_link 'Request to join'
  end
  
end