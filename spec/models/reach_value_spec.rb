require 'spec_helper'

describe ReachValue do

  let(:project) {FactoryGirl.create(:project)}

  describe ".build_reach_value" do

    let (:reach_value_literal) { "12" }
    let (:reach_value) { ReachValue.build_reach_value(project, reach_value_literal) }

    it "should set the project uri" do
      reach_value.activity.should == project.uri
    end

    it "should set the dataset correctly" do
      reach_value.dataset.should == 'http://data.digitalsocial.eu/data/reach'
    end

    it "should set the measure_type to the right value" do
      reach_value.measure_type.should_not be_nil
      reach_value.measure_type.should == ReachValue.determine_measure_type_uri(project)
    end

    it "should set the ref period to now(ish)" do
      reach_value.ref_period.should_not be_nil
      (Time.now - reach_value.ref_period).should be < 2 #check within a second or two of now
    end

    it "should set the reach value literal" do
      reach_value.reach_value_literal.value.to_s.should == reach_value_literal.to_s
    end

  end

  describe "#reach_value_literal=" do

    let (:reach_value) { ReachValue.build_reach_value(project, "5") }

    it "should set the reach value literal" do
      reach_value.reach_value_literal = "10"
      reach_value.reach_value_literal.value.to_s.should == 10.to_s
    end

    context "when the activity type is not other" do
      it "should cast the literal to an xsd int" do
        reach_value.reach_value_literal = "10"
        reach_value.reach_value_literal.datatype.should == RDF::XSD.integer
      end
    end

    context "when the activity type is other" do
      it "should cast the literal to an xsd string" do
        reach_value.stub(:activity_type_slug){ "other" }
        reach_value.reach_value_literal = "15"
        reach_value.reach_value_literal.datatype.should == RDF::XSD.string
      end
    end


  end

end