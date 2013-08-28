require 'spec_helper'

feature 'Respond to user request' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  
  background do
    requestor = FactoryGirl.create(:user, first_name: 'Bob', email: 'bob@test.com')
    FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, user: requestor)
    
    organisation.update_attribute :name, 'Swirrl'

    login_as user, scope: :user
    visit user_path
  end

  scenario 'Should see project invite' do
    page.should have_content "Bob (bob@test.com) has requested to join Swirrl"
  end

  scenario 'Should allow request to be accepted' do
    click_link 'Accept'

    page.should have_content "request has been accepted"
    page.should_not have_content "Bob (bob@test.com) has requested to join Swirrl"
  end

  scenario 'Should allow request to be rejected' do
    click_link 'Ignore'

    page.should_not have_content "Bob (bob@test.com) has requested to join Swirrl"
    page.should_not have_content "request has been accepted"
  end

  scenario 'Should add requested user to users list if accepted' do
    click_link 'Accept'

    within('.users') do
      page.should have_content 'bob@test.com'
    end
  end

  scenario 'Should not add requested user to users list if rejected' do
    click_link 'Ignore'

    within('.users') do
      page.should_not have_content 'bob@test.com'
    end
  end
  
end