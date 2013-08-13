module TagFields

  extend ActiveSupport::Concern

  included do
    class_attribute :tag_fields
    self.tag_fields = []
  end

  module ClassMethods

    def tag_field(name, predicate, tag_class)
      # make a field
      field name, predicate, {is_uri: true, multivalued: true}

      # make getters and setters for string lists.
      create_list_getter(name, tag_class)
      create_list_setter(name, tag_class)
    end

    def create_list_getter(field_name, tag_class)
      re_define_method("#{field_name}_list") do
        self.send(field_name).map { |uri| tag_class.find(uri).label }.join(", ")
      end
    end

    def create_list_setter(field_name, tag_class)
      re_define_method("#{field_name}_list=") do |comma_separated_str|
        tags = comma_separated_str.split(",").map &:strip
        uris = tags.map {|t| tag_class.from_label(t).uri }
        self.send("#{field_name}=", uris)
      end
    end

  end

end
