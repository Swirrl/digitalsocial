require "spec_helper"

class TestTag
  include Tripod::Resource

  include Tag
  uri_root 'http://example.com/def/concept/test/'
  concept_scheme_uri 'http://example.com/def/concept-scheme/test'
  broad_concept_uri (resource_uri_root + 'other')
end

describe Tag do

  # make sure we're clean before we start (the normal spec-helper deletes wont catch everything)
  before(:each) { TestTag.all.resources.map &:destroy}

  # this will catch all the concept schemes etc
  before(:each) do
    Tripod::SparqlClient::Update.update("
      DELETE {
        graph <#{TestTag.get_graph_uri.to_s}> {
          ?s ?p ?o .
        }
      }
      WHERE {
        graph <#{TestTag.get_graph_uri.to_s}> {
          ?s ?p ?o .
        }
      };
    ")
  end

  describe ".new" do
    it "should set the concept scheme" do
      t = TestTag.new('http://test.tag')
      t.in_scheme.should == 'http://example.com/def/concept-scheme/test'
    end
  end

  describe ".from_label" do

    context "top-level" do

      context "when the concept scheme does't exist" do

        it "shouldn't be there to start with!" do #insania check
          expect {ConceptScheme.find(TestTag.resource_concept_scheme_uri.to_s)}.to raise_error(Tripod::Errors::ResourceNotFound)
        end

        it "should make the concept scheme" do
          t = TestTag.from_label('top level', top_level:true)
          c = ConceptScheme.find(TestTag.resource_concept_scheme_uri.to_s) #shouldn't error
          c.should_not be_nil
        end

      end

      context "when the concept scheme does exist" do

        let!(:concept_scheme) do
          cs = ConceptScheme.new(TestTag.resource_concept_scheme_uri.to_s, TestTag.get_graph_uri)
          cs.save!
          cs
        end

        it "should use the exising concept scheme" do
          t = TestTag.from_label('top level', top_level:true)
          cs = ConceptScheme.find(concept_scheme.uri.to_s)
          cs.has_top_concept.length.should == 1 # check it's wired it up
        end
      end

      it "should set the top concept to include the tag(s)" do
        t = TestTag.from_label('top level', top_level:true)
        t2 = TestTag.from_label('top level 2', top_level:true)
        c = ConceptScheme.find(TestTag.resource_concept_scheme_uri.to_s) #shouldn't error
        c.has_top_concept.length.should == 2
        c.has_top_concept.last.to_s.should == 'http://example.com/def/concept/test/top-level'
        c.has_top_concept.first.to_s.should == 'http://example.com/def/concept/test/top-level-2'
      end

    end

    context "non top-level" do

      # create an 'other' tag as a broad top level concept
      let!(:broad) { TestTag.from_label('Other', top_level:true) }

      let(:label){ 'hello world' }

      it "should return an instance of the class" do
        TestTag.from_label(label).class.should == TestTag
      end

      it "should set the uri on the returned class based on the slug" do
        TestTag.from_label(label).uri.to_s.should == 'http://example.com/def/concept/test/hello-world'
      end

      it "should set the broad concept against the resource" do
        t = TestTag.from_label(label)
        t.broader.should == TestTag.resource_broad_concept_uri
      end

      it "should set the narrower predicate against the broad concept resource" do
        t = TestTag.from_label(label)
        t2 = TestTag.from_label('another label')

        broad_concept = TestTag.find(broad.uri)

        broad_concept.narrower.length.should == 2
        broad_concept.narrower.last.to_s.should == 'http://example.com/def/concept/test/hello-world'
        broad_concept.narrower.first.to_s.should == 'http://example.com/def/concept/test/another-label'
      end

      context "when the slug doesn't already exist" do
        it "should make a new tag" do
          expect { TestTag.from_label(label) }.to change{ TestTag.count }.by(1)
        end
      end

      context "when the slug already exists" do

        before { TestTag.from_label(label) }

        it "shouldn't make a new one" do
          expect { TestTag.from_label(label) }.not_to change{ TestTag.count }
        end
      end
    end
  end

  describe 'slugify_label_text(label)' do
    it "should create a slug from the label" do
      TestTag.slugify_label_text('Hello  world.').should == "hello-world"
    end
  end
end