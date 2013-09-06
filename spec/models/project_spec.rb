require 'spec_helper'

describe Project do

  let(:project) {FactoryGirl.create(:project)}

  context "when the activity type is not other" do
    context "when the reach value literal is non-numeric" do
      it "should be invalud" do
        project.reach_value_literal = 'twenty'
        project.should be_invalid
        project.errors[:reach_value_literal].should include("must be a whole number")
      end
    end

    context "when the reach value literal is numeric" do
      it "should be valid" do
        project.reach_value_literal = '20'
        project.should be_valid
      end
    end
  end

  context "when the activity type is other" do
    before do
      project.stub(:activity_type_slug){ "other" }
    end

    context "when the reach value literal is non-numeric" do
      it "should be valid" do
        project.reach_value_literal = 'twenty'
        project.should be_valid
      end
    end

    context "when the reach value literal is numeric" do
      it "should be valid" do
        project.reach_value_literal = '20'
        project.should be_valid
      end
    end

  end

  describe "#save_reach_value" do
    context "with no literal set" do
      it "should return true" do
        ReachValue.should_not_receive(:build_reach_value)
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

  describe "#network_metric" do

    context "when the activity type is not network" do
      it "should return nil" do
        project.network_metric.should be_nil
      end
    end

    context "when the activity type is network" do

      let (:project_individuals) { FactoryGirl.create(:project_with_network_activity) }
      let (:project_orgs) { FactoryGirl.create(:project_with_network_activity) }
      let (:reachless_project) { FactoryGirl.create(:project_with_network_activity) }

      before do
        project_individuals.network_metric = "individuals"
        project_individuals.reach_value_literal = "10"
        project_individuals.save_reach_value.should be_true

        project_orgs.network_metric = "organisations"
        project_orgs.reach_value_literal = "10"
        project_orgs.save_reach_value.should be_true
      end

      context "for existing reach resources" do

        # look it up again so we don't use memoized version
        let(:project_individuals_reloaded) { Project.find(project_individuals.uri) }
        let(:project_orgs_reloaded) { Project.find(project_orgs.uri) }

        it "should use the latest reach resource" do
          project_individuals_reloaded.should_receive(:latest_reach_value_resource).and_call_original
          project_individuals_reloaded.network_metric
        end

        context "when the measure type is organizations" do
          it "should return organisations" do
            project_orgs_reloaded.network_metric.should == "organisations"
          end
        end

        context "when the measure type is individuals" do
          it "should return organisations" do
            project_individuals_reloaded.network_metric.should == "individuals"
          end
        end

        context "when there's no reach value resource" do
          it "should default to organisations" do
            reachless_project.network_metric(:new_resource => true).should == "organisations"
          end
        end

      end

      context "for new reach resources" do

        it "should use the locally set reach resource" do
          project_individuals.should_not_receive(:latest_reach_value_resource)
          project_individuals.network_metric(:new_resource => true).should == "individuals"
        end
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