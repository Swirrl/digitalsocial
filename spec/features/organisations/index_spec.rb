require 'spec_helper'

feature 'Organisation index spec' do

  background do
    FactoryGirl.create(:organisation, name: 'Qwerty')
  end

  scenario 'Organisations are listed' do
    visit organisations_path
    page.should have_content 'Qwerty'
  end

  scenario 'Search for an existing organisation' do
    visit organisations_path(q: 'qwerty')
    page.should have_content 'Qwerty'
  end

  scenario 'Search for an non existing organisation' do
    visit organisations_path(q: 'foobar')
    page.should_not have_content 'Qwerty'
  end
  
end