class AssertionError < StandardError ; end

class TreeData
  # Accepts either a Project or an Organisation and generates the
  # data for the tree view visualisation.
  def initialize node, depth, root=nil
    @root = root
    @node = node
    @depth = depth

    assert_valid
  end

  def to_json
    {
     :node_data => self.common_details,
     :children => self.child_nodes
    }
  end

  def child_nodes
    @node.child_nodes.reject { |n|
      n == @root # filter out the root organisation
    }.map { |c|
      TreeData.new(c, @depth - 1, @root).to_json
    } unless @depth == 0
  end

  def common_details
    kind = @node.class.to_s.downcase
    hash = {
            :uri_slug => "/#{kind}s/#{@node.uri_slug}",
            :resource_type => kind,
            :name => @node.name,
            :more_details => @node.more_details
           }
    hash = maybe_add_organisation_type(hash)
    maybe_add_activity_type(hash)
  end

  private

  def maybe_add_organisation_type hash
    if @node.class == Organisation
      if @node.organisation_type.present?
        hash['organisation_type'] = @node.organisation_type.to_s
        hash['organisation_type_label'] = Concepts::OrganisationType.find(@node.organisation_type).label
      end
    end
    hash
  end

  def maybe_add_activity_type hash
    if @node.class == Project
      ac_type = @node.activity_type_resource

      ac_kind = Concepts::ActivityType.top_level_concepts.include?(ac_type) ? ac_type : Concepts::ActivityType.find('http://data.digitalsocial.eu/def/concept/activity-type/other')

      hash[:activity_type] = {:uri => ac_type.uri.to_s,
                              :name => ac_type.label,
                              :type => ac_kind.uri.to_s }
      hash
    else
      hash
    end
  end

  def assert_valid
    allowed_nodes = [Project, Organisation]
    unless allowed_nodes.include?(@node.class) && allowed_nodes.append(nil.class).include?(@root.class)
      raise AssertionError, "Only nodes of type #{allowed_nodes.join(', ')} are supported."
    end
  end
end
