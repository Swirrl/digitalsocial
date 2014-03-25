require 'spec_helper'

feature 'Edit organisation location' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit edit_location_organisation_path(organisation)
  end

  scenario 'Updating the organisation location successfully' do
    fill_in 'Street address', with: '120 Grosvenor Street'
    fill_in 'Locality', with: 'Manchester'
    fill_in 'Region', with: 'Greater Manchester'
    select 'United Kingdom', from: 'Country', match: :first
    fill_in 'Postal code', with: 'M1 7HL'
    fill_in 'Lat', with: '53.4701805'
    fill_in 'Lng', with: '-2.2371639'

    click_button 'Update'

    page.current_path.should == edit_location_organisation_path(organisation.guid)
  end

  scenario 'Updating the organisation location unsuccessfully' do
    fill_in 'Lat', with: ''
    fill_in 'Lng', with: ''

    click_button 'Update'

    page.current_path.should_not == edit_location_organisation_path(organisation.guid)
  end

  
end