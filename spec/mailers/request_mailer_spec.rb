require "spec_helper"

describe RequestMailer do

  describe ".request_digest" do

    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }

    let(:organisation) { user.organisation_resources.first }
    let(:other_org) { FactoryGirl.create(:organisation) }
    let(:project) { FactoryGirl.create(:project) }

    it 'should be set to be delivered to the email passed in' do
      RequestMailer.request_digest(user, organisation).should deliver_to(user.email)
    end

    it 'should contain the names of the projects they are invited to' do
      inv = FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: true)

      RequestMailer.request_digest(user, organisation).should have_body_text(project.name)
    end

    it 'should contain the names of the organisations that made requests and the projects they want to join' do
      pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
      request = FactoryGirl.create(:project_request, project_uri: pm.project.to_s, requestor_organisation_uri: other_org.uri.to_s, open: true)

      RequestMailer.request_digest(user, organisation).should have_body_text(other_org.name)
      RequestMailer.request_digest(user, organisation).should have_body_text(pm.project_resource.name)
    end

    it 'should contain a link to the dashboard path of the organisation' do
     inv = FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: true)

      RequestMailer.request_digest(user, organisation).should have_body_text("/dashboard?org_id=#{organisation.guid}")
    end

    it 'should contain the details of users to be added' do
      pending_user = FactoryGirl.create(:user)
      FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, open: true, user: pending_user)

      RequestMailer.request_digest(user, organisation).should have_body_text(pending_user.first_name)
      RequestMailer.request_digest(user, organisation).should have_body_text(pending_user.email)
    end

    it 'should not contain the details of users whose requests have been responded to' do
      pending_user = FactoryGirl.create(:user)
      accepted_user = FactoryGirl.create(:user)

      FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, open: true, user: pending_user)
      FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, open: false, accepted: true, user: accepted_user)

      RequestMailer.request_digest(user, organisation).should_not have_body_text(accepted_user.first_name)
      RequestMailer.request_digest(user, organisation).should_not have_body_text(accepted_user.email)
    end

  end

end
