module Tag

  extend ActiveSupport::Concern

  included do
    class_attribute :resource_uri_root
    class_attribute :resource_concept_scheme
    class_attribute :broad_concept

    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true
    field :label, RDF::RDFS.label
    field :sub_class_of, RDF::SKOS.subClassOf, :is_uri => true
    field :broader, RDF::SKOS.broader, :is_uri => true
    field :narrower, RDF::SKOS.narrower, :is_uri => true, :multivalued => true

    def initialize(uri, graph_uri=nil)
      super
      self.in_scheme = self.class.resource_concept_scheme
      self.sub_class_of = RDF::SKOS.Concept
    end
  end

  module ClassMethods

    def concept_scheme(cs_uri)
      self.resource_concept_scheme = cs_uri
      graph_uri cs_uri.to_s.gsub('/def/', '/graph/')
    end

    def broad_concept_uri(uri)
      self.broad_concept = uri
    end

    def uri_root(root)
      self.resource_uri_root = root
      self.resource_uri_root += "/" unless resource_uri_root[-1] == "/"
    end

    # these are just the top-concepts
    def top_level_tags
      # need a custom query here as the concept scheme in diff. graph
      self.find_by_sparql("
        SELECT ?uri (<#{self.get_graph_uri}> as ?graph) WHERE {

          <#{self.resource_concept_scheme.to_s}> <#{RDF::SKOS.hasTopConcept}> ?uri .

          GRAPH <#{self.get_graph_uri}> {
            ?uri ?p ?o .
          }

        }"
      )
    end

    # makes or finds an instance of this type
    # options :top_level => true (indicates that this is a 'top-level' concept).
    def from_label(label, opts={})

      slug = self.slugify_label_text(label)

      # If there's a slug match, it's near enough that they meant the same thing so
      # just look up by uri
      begin
        resource = self.find( self.uri_from_slug(slug) )
      rescue Tripod::Errors::ResourceNotFound
        # if don't find one, make one
        transaction = Tripod::Persistence::Transaction.new

        resource = self.new(self.uri_from_slug(slug))
        resource.label = label

        if (opts[:top_level])
          # add this as a top level concept to the concept scheme
          # (ONLY USED FOR SEEDING)

          # find the concept scheme, or make it if it doesn't exist
          cs = nil
          begin
            cs = ConceptScheme.find(self.resource_concept_scheme.to_s)
          rescue Tripod::Errors::ResourceNotFound
            cs = ConceptScheme.new(self.resource_concept_scheme.to_s, self.get_graph_uri)
          end

          # add to the top concepts
          cs.has_top_concept = cs.has_top_concept << resource.uri
          cs.save!(:transaction => transaction)

        elsif self.broad_concept
          # set the broader/narrower relation up for non-top-level ones
          # (only if the broad concept is set at class level
          broad_concept = self.find( self.broad_concept ) # this should always exist
          broad_concept.narrower = broad_concept.narrower << resource.uri
          broad_concept.save!(:transaction => transaction)
          resource.broader = self.broad_concept
        end

        resource.save!(:transaction => transaction)

        transaction.commit

        resource #return the res.
      end

    end

    def slug_from_uri(uri)
      uri.to_s.split('/').last
    end

    def slugify_label_text(label)
      label
        .downcase.strip
        .gsub('  ', ' ') # remove double spaces
        .gsub(' ', '-') # replaces spaces with hyphens
        .gsub(/[^0-9a-z\-]*/, '')  # remove anything except nos and letters and hyphens
    end

    def uri_from_slug(slug)
      resource_uri_root + slug
    end

  end

end