class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # Override the create method to handle super admin creation
  def create
    build_resource(sign_up_params)

    # Set super_admin flag for super@example.com
    resource.super_admin = true if resource.email == "super@example.com"

    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # Override the update method to allow profile picture updates without password
  def update
    # Check if we're only updating permitted parameters that don't require password
    if only_updating_allowed_attributes?
      remove_password_params_if_blank
      resource.update_without_password(account_update_params)
      if resource.valid?
        set_flash_message :notice, :updated
        bypass_sign_in(resource)
        respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      # Use the default update method if we're updating sensitive attributes
      super
    end
  end

  protected

  # Parameters that don't require password verification
  def no_password_attributes
    [ :first_name, :last_name, :profile_picture, :remove_profile_picture, :super_admin ]
  end

  # Check if the update only includes attributes that don't require password
  def only_updating_allowed_attributes?
    return true if params[:commit_section] == "profile"

    if params[:user]
      attrs = params[:user].keys.map(&:to_sym)
      (attrs - no_password_attributes).empty?
    else
      false
    end
  end

  # Remove password params if they're blank to prevent validation errors
  def remove_password_params_if_blank
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
      params[:user].delete(:current_password)
    end
  end

  # Configure permitted parameters for sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :profile_picture, :remove_profile_picture, :super_admin ])
  end

  # Configure permitted parameters for account updates
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :profile_picture, :remove_profile_picture, :super_admin ])
  end
end
