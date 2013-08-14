require "spec_helper"

class TestTag
  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/test'

  include Tag
  uri_root 'http://example.com/def/concept/test/'
  concept_scheme 'http://example.com/def/concept-scheme/test'
end


class TestModel
  include Tripod::Resource
  include TagFields

  tag_field :taggy, 'http://example.com/def/taggy', TestTag
end

describe TagFields do

  describe 'tag_field' do
    it "should create a field with the symbol" do
      TestModel.fields.keys.should include(:taggy)
    end

    it "should set the is_uri option" do
      TestModel.fields[:taggy].options[:is_uri].should be_true
    end

    it "should set the multivalued option" do
      TestModel.fields[:taggy].options[:multivalued].should be_true
    end

    it "should create a getter and setter for the list" do
      t = TestModel.new('http://test.model')
      t.taggy_list = "abc, def"
      t.taggy_list.should == "abc, def"
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

end