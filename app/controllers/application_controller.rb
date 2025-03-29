class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_global_data
  before_action :check_impersonation

  # Define helper methods for Devise authentication
  def user_signed_in?
    !!current_user
  end

  def after_sign_in_path_for(resource)
    # If returning from impersonation, go to super admin dashboard
    if session[:return_to_super_admin]
      session.delete(:return_to_super_admin)
      super_admin_dashboard_path
    else
      dashboard_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :profile_picture ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :profile_picture, :remove_profile_picture ])
  end

  def load_global_data
    @featured_products = Product.where(featured: true).order(created_at: :desc).limit(3)
    @cart_count = current_user&.cart&.items&.count || 0 rescue 0
  end

  # Check if a super admin is impersonating another user
  def check_impersonation
    if user_signed_in? && session[:admin_id].present?
      @impersonating = true
    end
  end

  # Used in views to check if current session is impersonating
  helper_method :impersonating?
  def impersonating?
    @impersonating || false
  end
end
