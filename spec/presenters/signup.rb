require 'spec_helper'

describe Signup do

  describe "validations" do
    let(:signup) { FactoryGirl.build(:signup) }

    context "details" do
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
    end
  end

end
