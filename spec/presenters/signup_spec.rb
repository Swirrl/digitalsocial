require 'spec_helper'

describe Signup do

  let(:signup) { FactoryGirl.build(:signup) }

  describe "validations" do

    it "must have a valid factory" do
      signup.should be_valid
    end

    it "must have a first name" do
      signup.first_name = ""
      signup.should_not be_valid
    end

    it "must have an email" do
      signup.email = ''
      signup.should_not be_valid
    end

    it "must have a password" do
      signup.password = ''
      signup.should_not be_valid
    end

    it "must have a valid email" do
      signup.email = 'test@example'
      signup.should_not be_valid
    end

    it "must have a unique email" do
      signup_with_same_email = FactoryGirl.build(:signup, email: "name@example.com")
      signup_with_same_email.save
      
      signup.email = 'name@example.com'
      signup.should_not be_valid
    end

    it "must have an organisation name" do
      signup.organisation_name = ''
      signup.should_not be_valid
    end

    it "must have an organisation lat" do
      signup.organisation_lat = nil
      signup.should_not be_valid
    end

    it "must have an organisation lng" do
      signup.organisation_lng = nil
      signup.should_not be_valid
    end

  end

  describe "resource creation" do

    it "must create an organisation with the correct details" do
      signup.save

      signup.organisation.should be_persisted
      signup.organisation.name.should == signup.organisation_name
    end

    it "must create a site with the correct details" do
      signup.save

      signup.site.should be_persisted
      signup.site.lat.should == signup.organisation_lat
      signup.site.lng.should == signup.organisation_lng
    end

    it "must create a user with the correct details" do
      signup.save

      signup.user.should be_persisted
      signup.user.first_name.should == signup.first_name
      signup.user.email.should      == signup.email
      signup.user.password.should   == signup.password
    end

  end

  describe "resource associations" do

    it "must associate the organisation with the site" do
      signup.save

      signup.organisation.primary_site_resource.should == signup.site
    end

    it "must associate the user with the organisation" do
      signup.save

      signup.user.organisation_resources.should include(signup.organisation)
    end

  end

end
