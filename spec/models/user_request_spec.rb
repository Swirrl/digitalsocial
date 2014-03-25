require 'spec_helper'

describe UserRequest do

  let(:user_request) { FactoryGirl.create(:user_request) }

  describe "#accept" do

    it "should send an email to the accepted organisation's members" do
      lambda { user_request.accept! }.should change(ActionMailer::Base.deliveries, :count).by(1)
    end

  end

end