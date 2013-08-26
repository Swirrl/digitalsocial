class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

  helper_method :current_organisation

	protected

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
	  	user_path
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
