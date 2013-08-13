require 'spec_helper'

describe User do
  
  context 'validations' do

    let(:user) { FactoryGirl.build(:user) }

    it 'must have a valid factory' do
      user.should be_valid
    end

  end

  context 'sending request digests' do

    before(:each) do
      ActionMailer::Base.deliveries = []
      Request.destroy_all
    end

    describe '.send_request_digests' do

      context 'one organisation' do

        let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
        let(:organisation) { user.organisation_resources.first }
        
        it 'should not send any emails if not pending requests' do
          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

        it 'should send an email if a user has pending invites' do
          FactoryGirl.create(:request, requestor: organisation, is_invite: true, responded_to: false)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should send an email if a user has pending requests' do
          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          FactoryGirl.create(:request, is_invite: false, responded_to: false, requestable: pm.project_resource)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should only send one email if a user has multiple invites or requests' do
          FactoryGirl.create(:request, requestor: organisation, is_invite: true, responded_to: false)
          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          FactoryGirl.create(:request, is_invite: false, responded_to: false, requestable: pm.project_resource)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should not send an email if the requests have been responded to' do
          5.times { FactoryGirl.create(:request, requestor: organisation, is_invite: true, responded_to: true) }

          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

      end

      context 'multiple organisations' do

        let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 3) }

        it 'should send separate emails to the same user if they are part of more than one organisation' do
          user.organisation_resources.each do |organisation|
            FactoryGirl.create(:request, requestor: organisation, is_invite: true, responded_to: false)
          end

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(3)
        end

      end

    end

  end

end
