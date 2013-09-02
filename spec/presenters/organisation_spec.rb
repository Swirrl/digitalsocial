require 'spec_helper'

describe OrganisationPresenter do

  let(:organisation_presenter) { FactoryGirl.build(:organisation_presenter) }

  describe "validations" do

    it "must have a valid factory" do
      organisation_presenter.should be_valid
    end

  end

  describe "resource creation" do

    it "must create an organisation with the correct details" do
      organisation_presenter.save

      organisation_presenter.organisation.should be_persisted
      organisation_presenter.organisation.name.should == organisation_presenter.name
    end

    it "must create a site with the correct details" do
      organisation_presenter.save

      organisation_presenter.site.should be_persisted
      organisation_presenter.site.lat.should == organisation_presenter.lat
      organisation_presenter.site.lng.should == organisation_presenter.lng
    end

  end

  describe "resource associations" do

    it "must associate the organisation with the site" do
      organisation_presenter.save

      organisation_presenter.organisation.primary_site_resource.should == organisation_presenter.site
    end

    it "must associate the user with the organisation" do
      organisation_presenter.save

      organisation_presenter.user.organisation_resources.should include(organisation_presenter.organisation)
    end

  end

end
