require 'spec_helper'

feature 'Organisation index spec' do

  scenario 'Organisations are listed' do
    FactoryGirl.create(:organisation, name: 'Qwerty')
    visit organisations_path

    page.should have_content 'Qwerty'
  end
  
end