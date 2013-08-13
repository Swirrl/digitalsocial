module Tag

  extend ActiveSupport::Concern

  included do
    class_attribute :resource_uri_root
    class_attribute :resource_concept_scheme

    rdf_type RDF::SKOS.Concept
    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true
    field :label, RDF::RDFS.label

    def initialize(uri, graph_uri=nil)
      super
      self.in_scheme = self.class.resource_concept_scheme
    end
  end

  module ClassMethods

    def concept_scheme(cs)
      self.resource_concept_scheme = cs
    end

    def uri_root(root)
      self.resource_uri_root = root
      self.resource_uri_root += "/" unless resource_uri_root[-1] == "/"
    end

    # makes or finds an instance of this type
    def from_label(label)

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
        resource = self.new(self.uri_from_slug(slug))
        resource.label = label
        resource.save!
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