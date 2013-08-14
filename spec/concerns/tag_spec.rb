require "spec_helper"

class TestTag
  include Tripod::Resource
  graph_uri 'http://example.com/graph/concept-scheme/test'

  include Tag
  uri_root 'http://example.com/def/concept/test/'
  concept_scheme 'http://example.com/def/concept-scheme/test'
end

describe Tag do

  describe ".new" do
    it "should set the concept scheme" do
      t = TestTag.new('http://test.tag')
      t.in_scheme.should == 'http://example.com/def/concept-scheme/test'
    end
  end

  describe ".from_label" do

    let(:label){ 'hello world' }

    it "should return an instance of the class" do
      TestTag.from_label(label).class.should == TestTag
    end

    it "should set the uri on the returned class based on the slug" do
      TestTag.from_label(label).uri.to_s.should == 'http://example.com/def/concept/test/hello-world'
    end

    context "when the slug doesn't already exist" do
      it "should make a new tag" do
        expect { TestTag.from_label(label) }.to change{ TestTag.count }.from(0).to(1)
      end
    end

    context "when the slug already exists" do

      before { TestTag.from_label(label) }

      it "shouldn't make a new one" do
        expect { TestTag.from_label(label) }.not_to change{ TestTag.count }
      end
    end
  end

  describe 'slugify_label_text(label)' do
    it "should create a slug from the label" do
      TestTag.slugify_label_text('Hello  world.').should == "hello-world"
    end
  end
end