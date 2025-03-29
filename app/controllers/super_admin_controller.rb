# frozen_string_literal: true

class SuperAdminController < ApplicationController
  include SuperAdminAuthorization
  before_action :authenticate_user!
  layout "super_admin"

  private

  def require_super_admin
    unless current_user&.super_admin?
      flash[:alert] = "You must be a super administrator to access this area."
      redirect_to root_path
    end
  end
end
