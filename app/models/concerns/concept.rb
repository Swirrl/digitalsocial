module Concept

  extend ActiveSupport::Concern

  included do
    class_attribute :resource_uri_root
    class_attribute :resource_concept_scheme_uri
    class_attribute :resource_broad_concept_uri
    class_attribute :resource_concept_scheme_label

    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true
    field :label, RDF::RDFS.label
    field :description, 'http://purl.org/dc/terms/description'
    field :sub_class_of, RDF::SKOS.subClassOf, :is_uri => true
    field :broader, RDF::SKOS.broader, :is_uri => true
    field :narrower, RDF::SKOS.narrower, :is_uri => true, :multivalued => true

    rdf_type RDF::SKOS.Concept

    def initialize(uri, graph_uri=nil)
      super
      self.in_scheme = self.class.resource_concept_scheme_uri
      self.sub_class_of = RDF::SKOS.Concept
    end

    def to_s
      str = label
      # str += " (#{description})" if description
      str
    end

    def top_level?
      self.class.top_level_concepts.collect(&:uri).include? self.uri
    end
  end

  module ClassMethods

    def concept_scheme_uri(cs_uri)
      self.resource_concept_scheme_uri = cs_uri
      graph_uri cs_uri.to_s.gsub('/def/', '/graph/')
    end

    def concept_scheme_label(cs_label)
      self.resource_concept_scheme_label = cs_label
    end

    def broad_concept_uri(uri)
      self.resource_broad_concept_uri = uri
    end

    def uri_root(root)
      self.resource_uri_root = root
      self.resource_uri_root += "/" unless resource_uri_root[-1] == "/"
    end

    # search existing concepts
    def search_for_label_starting_with(term)
      self.where("?uri <#{RDF::RDFS.label}> ?label").where("FILTER regex(?label, \"^#{term}\", \"i\")").resources
    end

    # these are just the top-concepts
    def top_level_concepts
      # need a custom query here as the concept scheme in diff. graph
      concepts = self.find_by_sparql("
        SELECT ?uri (<#{self.get_graph_uri}> as ?graph) WHERE {

          <#{self.resource_concept_scheme_uri.to_s}> <#{RDF::SKOS.hasTopConcept}> ?uri .

          GRAPH <#{self.get_graph_uri}> {
            ?uri ?p ?o .
          }

        }"
      )
      # force other to end and sort rest alphabetically
      others = concepts.select{|x| x.label.downcase == "other"}
      other = others.first


      if other
        concepts.delete_if{|x| x.label.downcase == "other"}
        concepts.sort{|x,y| x.label.downcase <=> y.label.downcase }.push(other)
      end
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

        if (opts[:top_level]) # (ONLY USED FOR SEEDING)
          add_top_level_concept(resource, transaction: transaction)
        elsif self.resource_broad_concept_uri # (only if the broad concept is set at class level)
          self.add_narrow_concept(resource, transaction: transaction)
        end

        resource.save!(:transaction => transaction)
        transaction.commit
      end

      resource #return the resource.

    end

    # add res as a top level concept to the concept scheme
    def add_top_level_concept(resource, opts={})
      # find the concept scheme, or make it if it doesn't exist
      cs = nil
      begin
        cs = ConceptScheme.find(self.resource_concept_scheme_uri.to_s)
      rescue Tripod::Errors::ResourceNotFound
        cs = ConceptScheme.new(self.resource_concept_scheme_uri.to_s, self.get_graph_uri)
        cs.label = self.resource_concept_scheme_label
      end

      # add to the top concepts
      cs.has_top_concept = cs.has_top_concept << resource.uri
      cs.save!(:transaction => opts[:transaction])
    end

    # set the broader/narrower relation up for non-top-level
    def add_narrow_concept(resource, opts={})
      broad_concept_res = self.find( self.resource_broad_concept_uri ) # this should always exist
      broad_concept_res.narrower = broad_concept_res.narrower << resource.uri
      broad_concept_res.save!(:transaction => opts[:transaction])
      resource.broader = self.resource_broad_concept_uri
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