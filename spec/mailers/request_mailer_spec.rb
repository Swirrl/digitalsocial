require "spec_helper"

describe RequestMailer do

  describe ".request_digest" do
  
    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
    let(:organisation) { user.organisation_resources.first }

    it 'should be set to be delivered to the email passed in' do
      RequestMailer.request_digest(user, organisation).should deliver_to(user.email)
    end

    it 'should contain the names of the projects they are invited to' do
      request = FactoryGirl.create(:project_request, requestor: organisation, is_invite: true, responded_to: false)

      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestable.label)
    end

    it 'should contain the names of the organisations that made requests and the projects they want to join' do
      pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
      request = FactoryGirl.create(:project_request, is_invite: false, responded_to: false, requestable: pm.project_resource)

      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestor.name)
      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestable.label)
    end

    it 'should contain a link to the projects path of the organisation' do
      request = FactoryGirl.create(:project_request, requestor: organisation, is_invite: true, responded_to: false)

      RequestMailer.request_digest(user, organisation).should have_body_text("/projects?auth_token=#{user.authentication_token}&org_id=#{organisation.guid}")
    end

  end

end
