# frozen_string_literal: true

module SuperAdmin
  class SessionsController < ApplicationController
    layout "super_admin_login"

    def new
      # If already logged in
      if user_signed_in?
        if current_user.super_admin?
          redirect_to super_admin_dashboard_path, notice: "You are already logged in as a super admin."
        elsif current_user.admin?
          redirect_to admin_dashboard_path, notice: "You are logged in as an admin but not a super admin. Please contact the system owner for super admin access."
        else
          redirect_to root_path, notice: "You are logged in but do not have super admin privileges. Please contact the system owner for access."
        end
      end
    end

    # Handle the super admin login process
    def create
      email = params[:email]
      password = params[:password]

      # Find the user by email
      user = User.find_by(email: email)

      # First check if we found a user with that email
      if user.nil?
        flash.now[:alert] = "Invalid email or password."
        render :new and return
      end

      # Verify the user is a super admin
      unless user.super_admin?
        flash.now[:alert] = "This account does not have super admin privileges."
        render :new and return
      end

      # Attempt to authenticate the user
      if user.valid_password?(password)
        sign_in(user)
        redirect_to super_admin_dashboard_path, notice: "Welcome to the super admin dashboard."
      else
        flash.now[:alert] = "Invalid email or password."
        render :new
      end
    end
  end
end
