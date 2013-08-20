require "spec_helper"

class TestTag
  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/test'

  include Tag
  uri_root 'http://example.com/def/concept/test/'
  concept_scheme 'http://example.com/def/concept-scheme/test'
  broad_concept_uri (resource_uri_root + 'other')
end


class TestModel
  include Tripod::Resource
  include TagFields

  tag_field :taggy, 'http://example.com/def/taggy', TestTag, :multivalued => true
  tag_field :taggy2, 'http://example.com/def/taggy', TestTag
end

describe TagFields do

  before do
    # create an 'other' tag as a broad top level concept
    other = TestTag.from_label('Other', top_level:true)
  end

  describe 'tag_field' do
    it "should create a field with the symbol" do
      TestModel.fields.keys.should include(:taggy)
    end

    it "should set the is_uri option" do
      TestModel.fields[:taggy].options[:is_uri].should be_true
    end

    it "should set the multivalued option passed" do
      TestModel.fields[:taggy].options[:multivalued].should be_true
      TestModel.fields[:taggy2].options[:multivalued].should be_false
    end

    it "should create a list getter and setter for the multivalued fields" do
      t = TestModel.new('http://test.model')
      t.taggy_list = "abc, def"
      t.taggy_list.should == "abc, def"
    end

    it "should create a label getter and setter for the single valued fields" do
      t = TestModel.new('http://test.model')
      t.taggy2_label = "foo"
      t.taggy2_label.should == "foo"
    end
  end

  describe "tag list setter" do
    it "should set the uris against the field" do
      t = TestModel.new('http://test.model')
      t.taggy_list = "abc, def"
      t.taggy.each do |tag|
        tag.class.should == RDF::URI
      end
      t.taggy.first.to_s.should == "http://example.com/def/concept/test/abc"
      t.taggy.last.to_s.should == "http://example.com/def/concept/test/def"
    end
  end

  describe "tag label setter" do
    it "should set the uri against the field" do
      t = TestModel.new('http://test.model')
      t.taggy2_label = "baz"
      t.taggy2.class.should == RDF::URI
      t.taggy2.to_s.should == "http://example.com/def/concept/test/baz"
    end
  end

end