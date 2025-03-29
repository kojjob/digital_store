# frozen_string_literal: true

module SuperAdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_super_admin
  end

  private

  def require_super_admin
    unless user_signed_in? && current_user&.super_admin?
      flash[:alert] = "You must be a super administrator to access this area."
      redirect_to user_signed_in? ? (current_user.admin? ? admin_dashboard_path : root_path) : super_admin_login_form_path
    end
  end
end
