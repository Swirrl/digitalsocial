class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

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
	  end
	end

	# Need to allow the current_user's "organisation scope"
	# to be set in the UI
	def current_organisation
		current_user.organisations.first
	end

end
