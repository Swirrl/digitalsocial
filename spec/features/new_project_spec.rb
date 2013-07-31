require 'spec_helper'

feature 'Creating a new project' do

  let(:user) { FactoryGirl.create(:user_with_organisations) }

  background do
    login_as user, scope: :user
  end

  # scenario 'Logged in user visits projects page' do

  # end
  
end