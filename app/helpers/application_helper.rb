module ApplicationHelper

  def project_membership_nature_options
    Concepts::ProjectMembershipNature.top_level_concepts.collect { |pmn| [pmn.label, pmn.uri] }
  end

  def project_options
    Project.all.resources.collect { |p| [p.label, p.uri] }
  end

  def organisation_options
    Organisation.all.resources.collect { |o| [o.name, o.uri] }
  end

  def current_organisation_membership
    current_user.organisation_memberships.where(organisation_uri: current_organisation.uri.to_s).first
  end

  def build_organisation_breadcrumbs(active_index)
    list_content = []
    build_organisation_steps.each_with_index do |label, n|
      list_content.push(content_tag(:li, content_tag(:span, label), class: build_organisation_breadcrumb_class(n, active_index)))
    end

    content_tag :ol, list_content.join(" ").html_safe, class: "breadcrumbs"
  end

  def build_organisation_steps
    ["About you", "Org basics", "Org details", "1st activity", "Activity details", "Activity invites"]
  end

  def build_organisation_breadcrumb_class(n, active_index)
    if n < active_index
      "complete"
    elsif n == active_index
      "active"
    else
      "incomplete"
    end
  end

  def project_start_date_options(opts={})
    years_ago = opts[:years_ago] || 10

    options = []
    options += (Date.today.year-years_ago..Date.today.year).to_a.reverse.collect do |year|
      months = (1..12).to_a.reverse.collect do |n|
        label = [Date::MONTHNAMES[n], year].join(" ")
        date  = Date.parse(label)

        label if date < Date.today
      end.compact

      [year, months]
    end

    options
  end

  def project_end_date_options(opts={})
    years_ahead = opts[:years_ahead] || 10

    options = []
    options.push([nil, [["Ongoing", nil]]])

    options += (Date.today.year..Date.today.year+years_ahead).to_a.collect do |year|
      months = (1..12).to_a.collect do |n|
        label = [Date::MONTHNAMES[n], year].join(" ")
        date  = Date.parse(label)

        label if date > Date.today
      end.compact

      [year, months]
    end

    options
  end

  def asteroid_image_path
    "/assets/asteroids/#{rand(5)+1}_70x70.png"
  end

end
