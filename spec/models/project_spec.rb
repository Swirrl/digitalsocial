require 'spec_helper'

describe Project do

  let(:project) {FactoryGirl.create(:project)}

  describe "#network_metric" do
    # TODO.
  end

  describe "#save_reach_value" do
    context "with no literal set" do
      it "should return true" do
        project.save_reach_value.should be_true
      end
    end

    context "with a literal set" do
      before do
        project.reach_value_literal = "100"
      end
      it "should create a new reach value resource " do

        ReachValue.should_receive(:build_reach_value).and_call_original
        project.save_reach_value.should be_true

      end
    end
  end

  describe "#reach_value_literal" do
    context "when reach value literal has been set" do
      before do
        project.reach_value_literal = "100"
      end

      it "should just return that" do
        project.should_not_receive(:latest_reach_value_resource)
        project.reach_value_literal.to_s.should == "100"
      end
    end

    context "when the reach value literal has not been set" do
      it "should look up the latest" do
        project.should_receive(:latest_reach_value_resource).and_call_original
        project.reach_value_literal
      end
    end

  end

  describe "#reach_value_literal=" do

    context "when the reach value has never been set before" do
      it "should set reach value changed to true" do
        project.reach_value_literal = "100"
        project.reach_value_changed?.should be_true
      end
    end


    context "when the reach value is the same as before" do
      before do
        project.reach_value_literal = "100"
        project.save_reach_value
      end

      it "should not set reach value changed" do
        project.reach_value_literal = "100"
        project.reach_value_changed?.should be_false
      end
    end

    context "when the reach value changes" do
      before do
        project.reach_value_literal = "100"
        project.save_reach_value
      end

      it "should set reach value changed" do
        project.reach_value_literal = "101"
        project.reach_value_changed?.should be_true
      end
    end

  end
end