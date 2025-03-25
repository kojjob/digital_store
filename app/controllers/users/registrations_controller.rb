class Users::RegistrationsController < Devise::RegistrationsController
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

  private

  # Parameters that don't require password verification
  def no_password_attributes
    [ :first_name, :last_name, :profile_picture, :remove_profile_picture ]
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
end
