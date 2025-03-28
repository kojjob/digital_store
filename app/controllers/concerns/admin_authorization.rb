module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_admin, except: [ :index, :show ]
  end

  private

  def require_admin
    unless user_signed_in? && current_user&.admin?
      flash[:alert] = "You must be an administrator to perform this action."
      redirect_to user_signed_in? ? root_path : new_user_session_path
    end
  end
end
