require 'spec_helper'

feature 'New organisation wizard step' do

  let(:user) { FactoryGirl.create(:user) }

  background do
    login_as user, scope: :user
    visit organisations_build_new_organisation_path
  end

  scenario 'Filling in new organisation step successfully' do
    fill_in 'Name', with: 'Test organisation'
    fill_in 'Street address', with: '120 Grosvenor Street'
    fill_in 'Locality', with: 'Manchester'
    fill_in 'Region', with: 'Greater Manchester'
    select 'United Kingdom', from: 'Country'
    fill_in 'Postal code', with: 'M1 7HL'
    fill_in 'Lat', with: '53.4701805'
    fill_in 'Lng', with: '-2.2371639'

    click_button 'Next step'

    page.current_url.should include("organisations/build/edit_organisation")
  end

  scenario 'Filling in new organisation step unsuccessfully' do
    click_button 'Next step'

    page.current_url.should_not include("organisations/build/edit_organisation")
  end

  scenario 'Suggest to join an existing organisation', js: true do
    FactoryGirl.create(:organisation, name: 'An amazing organisation')

    fill_in 'Name', with: 'amazin'

    page.should have_content 'An amazing organisation'
    page.should have_link 'Request to join'
  end

  scenario 'Prevent duplicate organisations from being added' do
    FactoryGirl.create(:organisation, name: 'DuplicateOrg')

    fill_in 'Name', with: 'DuplicateOrg'
    fill_in 'Street address', with: '120 Grosvenor Street'
    fill_in 'Locality', with: 'Manchester'
    fill_in 'Region', with: 'Greater Manchester'
    select 'United Kingdom', from: 'Country'
    fill_in 'Postal code', with: 'M1 7HL'
    fill_in 'Lat', with: '53.4701805'
    fill_in 'Lng', with: '-2.2371639'

    click_button 'Next step'

    page.current_url.should_not include("organisations/build/edit_organisation")
    page.should have_css('.error')
  end
  
end