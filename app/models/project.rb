# -*- coding: utf-8 -*-
class Project

  include Tripod::Resource
  include ConceptFields
  include TripodCache

  rdf_type 'http://data.digitalsocial.eu/def/ontology/Activity'
  graph_uri Digitalsocial::DATA_GRAPH

  field :name, 'http://www.w3.org/2000/01/rdf-schema#label'
  field :description, 'http://purl.org/dc/terms/description'
  field :webpage, 'http://xmlns.com/foaf/0.1/page', is_uri: true

  field :duration, 'http://purl.org/NET/c4dm/event.owl#time', is_uri: true
  field :creator, 'http://data.digitalsocial.eu/def/ontology/recordedBy', is_uri: true
  field :social_impact, 'http://data.digitalsocial.eu/def/ontology/socialImpact'

  concept_field :activity_type, 'http://data.digitalsocial.eu/def/ontology/activityType', Concepts::ActivityType
  concept_field :areas_of_society, 'http://data.digitalsocial.eu/def/ontology/areaOfSociety', Concepts::AreaOfSociety, multivalued: true
  concept_field :technology_focus, 'http://data.digitalsocial.eu/def/ontology/technologyFocus', Concepts::TechnologyFocus, multivalued: true
  concept_field :technology_method, 'http://data.digitalsocial.eu/def/ontology/technologyMethod', Concepts::TechnologyMethod, multivalued: true

  attr_accessor :scoped_organisation
  validates :terms, acceptance: true

  validates :name, :activity_type, presence: true
  validates :areas_of_society_list, :technology_focus_array, :technology_method_list, :social_impact, presence: true, :unless => :first_page?
  
  validate :ensure_scoped_organisation_has_membership

  validate :validate_reach_data_type
  validate :validate_network_metric

  validate :project_name_is_unique

  # override initialise
  def initialize(uri=nil, graph_uri=nil)
    super(uri || Project.slug_to_uri(Guid.new))
  end

  def self.slug_to_uri(slug)
    "http://data.digitalsocial.eu/id/activity/#{slug}"
  end

  def self.uri_to_slug(uri)
    uri.split("/").last
  end

  def guid
    self.uri.to_s.split("/").last
  end

  def to_param
    guid
  end

  def duration_resource
    TimeInterval.find(self.duration) if self.duration.present?
  end

  def start_date_label
    duration_resource.start_date.strftime("%B %Y") if self.duration.present? && duration_resource.start_date.present?
  end

  def start_date_label=(label)
    dr = self.duration.present? ? duration_resource : TimeInterval.new
    dr.start_date = label.present? ? Date.parse(label) : nil
    dr.save

    self.duration = dr.uri.to_s
    self.save
  end

  def end_date_label
    duration_resource.end_date.strftime("%B %Y") if self.duration.present? && duration_resource.end_date.present?
  end

  def end_date_label=(label)
    dr = self.duration.present? ? duration_resource : TimeInterval.new
    dr.end_date = label.present? ? Date.parse(label) : nil
    dr.save

    self.duration = dr.uri.to_s
    self.save
  end

  def duration_str
    str = ""
    str += start_date_label if start_date_label
    str += " - "
    str += end_date_label if end_date_label
    str
  end

  def creator_resource
    Organisation.find(self.creator)
  end

  def add_creator_memberships!
    creator_natures.reject(&:blank?).each do |nature|
      creator_membership = ProjectMembership.new
      creator_membership.project      = self.uri.to_s
      creator_membership.organisation = self.creator_resource.uri.to_s
      creator_membership.nature       = nature
      creator_membership.save

      self.save
    end
  end

  def organisation_natures
    return unless scoped_organisation.present?

    scoped_project_membership_resources.collect { |pm| pm.nature.to_s }
  end

  def scoped_project_membership_resources
    return unless scoped_organisation.present?

    scoped_organisation.project_memberships_for_project(self).resources
  end

  def organisation_natures=(natures)
    scoped_project_membership_resources.each(&:destroy)

    natures.reject(&:blank?).each do |nature|

      pm = ProjectMembership.new
      pm.project      = self.uri.to_s
      pm.organisation = self.scoped_organisation.uri.to_s
      pm.nature       = nature
      pm.save

      # self.save # Don't automatically save this object, as it can
                  # cause validations/errors to run before their time.
    end
  end

  def add_organisation(organisation, natures)
    self.scoped_organisation = organisation
    self.organisation_natures = natures
    self.save
  end

  def ensure_scoped_organisation_has_membership
    if scoped_organisation.present? && scoped_organisation.project_memberships_for_project(self).count.zero?
      errors.add(:organisation_natures, "can't be blank")
    end
  end

  def organisations
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    Organisation
      .where("?pm_uri <#{project_membership_project_predicate}> <#{self.uri}>")
      .where("?pm_uri <#{project_membership_org_predicate}> ?uri")
  end

  def natures_for_organisation(organisation)
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    project_membership_nature_predicate = ProjectMembership.fields[:nature].predicate.to_s

    Concepts::ProjectMembershipNature.find_by_sparql(
      "SELECT ?uri WHERE {
        ?pm_uri <#{project_membership_nature_predicate}> ?uri .
        ?pm_uri <#{project_membership_org_predicate}> <#{organisation.uri.to_s}> .
        ?pm_uri <#{project_membership_project_predicate}> <#{self.uri.to_s}> .
      }"
    )

  end

  def natures_str_for_organisation(organisation)
    natures_for_organisation(organisation).map(&:label).join(", ")
  end

  def organisation_resources
    organisations.resources
  end

  def any_organisations?
    organisations.count > 0
  end

  def image_url
    # TODO use a relevant image for project avatar
    "/assets/asteroids/#{rand(5)+1}_70x70.png"
  end

  def organisation_names
    organisation_resources.collect(&:name).join(", ")
  end

  def as_json(options = nil)
    json = {
      uri: self.uri.to_s,
      name: self.name,
      guid: self.guid,
      image_url: self.image_url,
      organisation_names: self.organisation_names
    }
    json
  end

  def self.search_by_name(search)
    name_predicate = self.fields[:name].predicate.to_s
    self.order_by_name.where("?uri <#{name_predicate}> ?name").where("FILTER regex(?name, \"\"\"#{search}\"\"\", \"i\")").resources
  end

  def activity_type_label_other=(other)
    self.activity_type_label = other if other.present?
  end

  def activity_type_label_other
    if activity_type_resource.present? && !activity_type_resource.top_level?
      self.activity_type_label
    end
  end

  def activity_type_slug
    activity_type_resource.slug if activity_type_resource
  end

  def activity_type_resource
    @activity_type_resource ||= Concepts::ActivityType.find(self.activity_type) if self.activity_type.present?
  end

  def technology_focus_array=(array)
    self.technology_focus_list = array.reject(&:blank?).join(",")
  end

  def technology_focus_array
    self.technology_focus_list.split(",").collect(&:strip)
  end

  def webpage_label=(domain)
    domain.strip!
    domain.gsub!(/^http:\/\//, "")
    self.webpage = domain.present? ? "http://#{domain}" : nil
  end

  def webpage_label
    self.webpage.to_s.gsub(/^http:\/\//, "") if self.webpage.present?
  end

  def self.order_by_name
    name_predicate = self.fields[:name].predicate.to_s
    where("?uri <#{name_predicate}> ?name").order("lcase(str(?name))")
  end

  def progress_percent
    @progress_percent ||=
      ((progress_count.to_f / Project.progress_attributes.length) * 100).round
  end

  def self.progress_attributes
    [:name, :description, :webpage, :start_date_label, :social_impact,
     :activity_type, :areas_of_society, :technology_focus, :technology_method]
  end

  def progress_count
    count = 0
    Project.progress_attributes.each do |attr|
      count += 1 if self.send(attr).present?
    end
    count
  end

  # REACH STUFF:
  ##############

  def validate_reach_data_type
    if @reach_value_literal && activity_type_slug != "other"
      @reach_value_literal = @reach_value_literal.to_s.strip
      errors.add(:reach_value_literal, "must be a whole number") unless !!(/^[\d]*$/.match(@reach_value_literal))
    else
      true
    end
  end

  def validate_network_metric
    if @reach_value && activity_type_slug == "network"
      errors.add(:network_metric, "must be chosen") unless ["organisations", "individuals"].include?(network_metric)
    end
  end

  # Get the network metric for this
  #
  # opts:
  # new_resource (true if we should use the newly built one, otherwise use latest existing).
  # TODO: This is hacktaculous - refactor this into a presenter of some kind?
  def network_metric(opts={})
    return @network_metric if @network_metric

    if activity_type_slug == "network"

      if opts[:new_resource] && @new_reach_value_resource
        rv_resource = @new_reach_value_resource
      else
        rv_resource = latest_reach_value_resource
      end

      if rv_resource
        measure_type_slug = rv_resource.measure_type.to_s.split('/').last

        if measure_type_slug.starts_with?("organ")
          "organisations"
        else
          "individuals"
        end
      else
        "organisations" # default
      end
    else
      nil
    end
  end

  # set the network metric for this project (only applies if activity type is network)"
  def network_metric=(val)
    @network_metric = val
  end

  def reach_value_changed?
    @reach_value_changed
  end

  def set_reach_value_changed!
    @reach_value_changed = true
  end

  def latest_reach_value_resource
    @latest_reach_value_resource ||= ReachValue.get_latest_reach_value_resource_for_activity(self)
  end

  # get the just set / latest reach value literal
  def reach_value_literal
    return @reach_value_literal if @reach_value_literal

    if latest_reach_value_resource
      @reach_value_literal ||= latest_reach_value_resource.reach_value_literal
    end
  end

  # set the reach value literal
  def reach_value_literal=(val)
    if ( (reach_value_literal.to_s != val.to_s) ) # has it changed?

      unless ( self.new_record? && val.blank? )
        # don't set changed if it's a new record and the value is blank
        self.set_reach_value_changed!
      end
    end

    @reach_value_literal = val
  end

  def save_reach_value(opts={})
    # we only build a new obs if it's changed
    if self.reach_value_changed?
      # builds a new observation and save it
      @new_reach_value_resource = ReachValue.build_reach_value(self, @reach_value_literal)
      result = @new_reach_value_resource.save(opts)
      @reach_value_changed = false #reset the changed flag
      result
    else
      true
    end
  end

  # As the creation process is multi-page, we provide a check to see
  # whether or not the object is valid for the first page, in which
  # case the controller can decide to save it into the session or
  # display errors.
  def valid_for_first_page?
    @first_page = true
    valid_so_far = self.valid?
    @first_page = false
    valid_so_far
  end

  # TODO remove when implemented in tripod
  def assign_attributes(attributes)
    attributes.each_pair do |name, value|
      send "#{name}=", value
    end
  end

  def only_organisation?(organisation)
    organisations.count == 1 && organisations.first == organisation
  end

  def unjoin(organisation)
    project_membership_project_predicate = ProjectMembership.fields[:project].predicate.to_s
    project_membership_org_predicate = ProjectMembership.fields[:organisation].predicate.to_s
    ProjectMembership
      .where("?uri <#{project_membership_project_predicate}> <#{self.uri.to_s}>")
      .where("?uri <#{project_membership_org_predicate}> <#{organisation.uri.to_s}>").resources.each do |pm|
        pm.destroy
    end
  end

  private

  def first_page?
    @first_page
  end
  
  def project_name_is_unique
    name_predicate = Project.fields[:name].predicate.to_s
    if Project.where("?uri <#{name_predicate}> \"\"\"#{name}\"\"\"").where("FILTER(?uri != <#{self.uri}>)").count > 0
      errors.add(:name, "Activity already exists")
    end
  end

end
