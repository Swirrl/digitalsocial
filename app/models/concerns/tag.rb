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
      self.where("<#{self.resource_concept_scheme.to_s} <#{RDF::SKOS.hasTopConcept}> ?uri")
    end

    # makes or finds an instance of this type
    # options :top_level => true (indicates that this is a 'top-level' concept).
    def from_label(label, opts={})

      slug = self.slugify_label_text(label)

      # If there's a slug match, it's near enough that they meant the same thing.
      resource = self
        .where("?uri ?p ?o")
        .where("FILTER(?uri = <#{self.uri_from_slug(slug)}>)") #same URI
        .first

      if resource
        # found one - return it.
        resource
      else
        # if don't find one, make one
        transaction = Tripod::Persistence::Transaction.new

        resource = self.new(self.uri_from_slug(slug))
        resource.label = label

        if (opts[:top_level])
          # add this as a top level concept to the concept scheme

          # find the concept scheme, or make it if it doesn't exist
          cs = nil
          begin
            cs = ConceptScheme.find(self.resource_concept_scheme.to_s)
          rescue Tripod::Errors::ResourceNotFound
            cs = ConceptScheme.new(self.resource_concept_scheme.to_s, self.get_graph_uri)
          end

          # add to the top concepts
          cs.has_top_concept = cs.has_top_concept << resource.uri.to_s
          cs.save!

        else
          # set the broader/narrower relation up for non-top-level ones
          # (only if the broad concept is set at class level)
          if self.broad_concept
            broad_concept = self.find( self.broad_concept ) # this should always exist
            broad_concept.narrower = broad_concept.narrower << resource.uri
            broad_concept.save!
            resource.broader = self.broad_concept
          end
        end

        resource.save!(:transaction => transaction)
        transaction.commit

        resource

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