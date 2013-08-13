require 'spec_helper'

describe SignupPresenter do

  let(:signup_presenter) { FactoryGirl.build(:signup_presenter) }

  describe "validations" do

    it "must have a valid factory" do
      signup_presenter.should be_valid
    end

    it "must have a first name" do
      signup_presenter.first_name = ""
      signup_presenter.should_not be_valid
    end

    it "must have an email" do
      signup_presenter.email = ''
      signup_presenter.should_not be_valid
    end

    it "must have a password" do
      signup_presenter.password = ''
      signup_presenter.should_not be_valid
    end

    it "must have a valid email" do
      signup_presenter.email = 'test@example'
      signup_presenter.should_not be_valid
    end

    it "must have a unique email" do
      signup_presenter_with_same_email = FactoryGirl.build(:signup_presenter, email: "name@example.com")
      signup_presenter_with_same_email.save
      
      signup_presenter.email = 'name@example.com'
      signup_presenter.should_not be_valid
    end

    it "must have an organisation name" do
      signup_presenter.organisation_name = ''
      signup_presenter.should_not be_valid
    end

    it "must have an organisation lat" do
      signup_presenter.organisation_lat = nil
      signup_presenter.should_not be_valid
    end

    it "must have an organisation lng" do
      signup_presenter.organisation_lng = nil
      signup_presenter.should_not be_valid
    end

  end

  describe "resource creation" do

    it "must create an organisation with the correct details" do
      signup_presenter.save

      signup_presenter.organisation.should be_persisted
      signup_presenter.organisation.name.should == signup_presenter.organisation_name
    end

    it "must create a site with the correct details" do
      signup_presenter.save

      signup_presenter.site.should be_persisted
      signup_presenter.site.lat.should == signup_presenter.organisation_lat
      signup_presenter.site.lng.should == signup_presenter.organisation_lng
    end

    it "must create a user with the correct details" do
      signup_presenter.save

      signup_presenter.user.should be_persisted
      signup_presenter.user.first_name.should == signup_presenter.first_name
      signup_presenter.user.email.should      == signup_presenter.email
      signup_presenter.user.password.should   == signup_presenter.password
    end

  end

  describe "resource associations" do

    it "must associate the organisation with the site" do
      signup_presenter.save

      signup_presenter.organisation.primary_site_resource.should == signup_presenter.site
    end

    it "must associate the user with the organisation" do
      signup_presenter.save

      signup_presenter.user.organisation_resources.should include(signup_presenter.organisation)
    end

  end

end
