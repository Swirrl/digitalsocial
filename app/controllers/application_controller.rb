class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

  helper_method :current_organisation

  rescue_from Exception, :with => :handle_uncaught_error
  rescue_from Tripod::Errors::ResourceNotFound, :with => :handle_resource_not_found
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :handle_resource_not_found
  rescue_from Tripod::Errors::Timeout, :with => :handle_timeout

	protected

  def show_partners
    @show_partners = true
  end

  def handle_resource_not_found(e)
    show_partners

    @show_partners = true
    respond_to do |format|
      format.html { render(:template => "errors/not_found", :status => 404) and return false }
      format.any { render(:text => "Not Found" ,:status => 404, :content_type => 'text/plain') and return false }
    end
  end

  def handle_timeout(e)
    show_partners

    @show_partners = true
    respond_to do |format|
      format.html { render(:template => "errors/timeout", :status => 503) and return false }
      format.any { render(:text => "Not Found" ,:status => 503, :content_type => 'text/plain') and return false }
    end
  end

  def handle_uncaught_error(e)

    @e = e

    if defined?(Raven)
      evt = Raven::Event.capture_rack_exception(e, request.env)
      Raven.send(evt) if evt
    end

    if Rails.env.development?
      #re-raise in dev mode.
      raise e
    else
      show_partners

      @show_partners = true
      respond_to do |format|
        format.html { render(:template => "errors/uncaught_error", :status => 500) and return false }
        format.any { render(:text => "Interal Server Error" ,:status => 500, :content_type => 'text/plain') and return false }
      end
    end

  end

	def layout_by_resource
	  if devise_controller? && resource_name == :admin
	    "admin"
	  else
	    "application"
	  end
	end

	def after_sign_in_path_for(resource)
	  if resource.is_a?(Admin)
	    admin_root_path
	  elsif resource.is_a?(User)
	  	dashboard_path
	  end
	end

  # given the last bit of the URI, set the org into the sesh
  def set_current_organisation(org_id)
    session[:org_id] = org_id
  end

	def current_organisation
    set_current_organisation(params[:org_id]) if params[:org_id]

		@current_organisation ||=
		  current_user.organisation_resources.find { |o| o.uri == "http://data.digitalsocial.eu/id/organization/#{session[:org_id]}" } ||
		  current_user.organisation_resources.first
	end

	def current_organisation_membership
    current_user.organisation_memberships.where(organisation_uri: current_organisation.uri.to_s).first
	end

	def override_with_other_params(opts={})
    opts[:scopes].each do |scope|
      next if params[scope].nil?

      params[scope].each do |label, value|
        if (other_value = params[scope]["#{label}_other"]).present?
          params[scope][label] = other_value
        end
      end

    end
  end

end
