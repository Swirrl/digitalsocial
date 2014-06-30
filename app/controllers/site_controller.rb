class SiteController < ApplicationController

  before_filter :set_title, except: [:index]

  before_filter :show_partners, except: [:index]

  def index
    @selected_panel = params[:selected_panel] || 'welcome_panel'
    render layout: false
  end

  def events
    #@page = Page.where(path: 'events').first
    @active_header = 'events'
  end

  def about
    @page = Page.where(_slugs: ["about"]).first
  end

  def resources
  end

  def community
  end

  def beta
    render layout: 'white'
  end

  def search
    filter = ""

    if params[:q].present?
      @query = params[:q]
      filter = "FILTER (regex(?name,'#{@query}','i'))"
    else
      @letter = params[:letter] ? params[:letter].upcase : 'A'
      filter = "FILTER (regex(?name,'^#{@letter}','i'))"
    end

    query = "SELECT DISTINCT ?res ?name WHERE {
      { ?res a <http://www.w3.org/ns/org#Organization> } UNION { ?res a <http://data.digitalsocial.eu/def/ontology/Activity> } .
      ?res <http://www.w3.org/2000/01/rdf-schema#label> ?name .
      #{filter}
    } ORDER BY (?name)"

    @results = Tripod::SparqlClient::Query.select(query)
    #@results.sort! { |a, b| a['name']['value'].upcase.gsub(/\W/, '') <=> b['name']['value'].upcase.strip.gsub(/\W/, '') }

    @active_header = 'search'
    @skip_container = true
    @main_class = 'grey'
    
    render layout: 'white'
  end

  private

  def set_title
    @title = params[:action].titleize
  end


end
