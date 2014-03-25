module ConceptFields

  extend ActiveSupport::Concern

  included do
    class_attribute :concept_fields
    self.concept_fields = []
  end

  module ClassMethods

    def concept_field(name, predicate, concept_class, opts={})
      # make a field
      field name, predicate, opts.merge({is_uri: true})

      # make getters and setters for string lists.
      if opts[:multivalued]
        create_list_getter(name, concept_class)
        create_list_setter(name, concept_class)
      else
        create_label_getter(name, concept_class)
        create_label_setter(name, concept_class)
      end

    end

    def create_label_getter(field_name, concept_class)
      re_define_method("#{field_name}_label") do
        uri = self.send(field_name)
        concept_class.find(uri).label if uri
      end
    end

    def create_label_setter(field_name, concept_class)
      re_define_method("#{field_name}_label=") do |label_str|
        tag = label_str.strip
        uri = concept_class.from_label(tag).uri
        self.send("#{field_name}=", uri)
      end
    end

    def create_list_getter(field_name, concept_class)
      re_define_method("#{field_name}_list") do
        self.send(field_name).map { |uri| concept_class.find(uri).label }.join(", ")
      end
    end

    def create_list_setter(field_name, concept_class)
      re_define_method("#{field_name}_list=") do |comma_separated_str|
        tags = comma_separated_str.split(",").map &:strip
        uris = tags.map {|t| concept_class.from_label(t).uri }
        self.send("#{field_name}=", uris)
      end
    end

  end

end
