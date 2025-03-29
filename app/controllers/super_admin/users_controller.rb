# frozen_string_literal: true

module SuperAdmin
  class UsersController < SuperAdminController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :impersonate, :toggle_admin ]

    def index
      @users = User.all.order(created_at: :desc).page(params[:page]).per(20)

      # Apply role filter if provided
      if params[:role].present?
        @role = params[:role]
        case @role
        when "admin"
          @users = @users.where(admin: true)
        when "super_admin"
          @users = @users.where(super_admin: true)
        when "seller"
          @users = @users.joins(:seller)
        when "buyer"
          @users = @users.where.not(id: Seller.select(:user_id))
        end
      end

      # Apply search if provided
      if params[:search].present?
        @search = params[:search].strip
        @users = @users.where("email LIKE ? OR first_name LIKE ? OR last_name LIKE ?",
                              "%#{@search}%", "%#{@search}%", "%#{@search}%")
      end
    end

    def show
      # User activity
      @activities = @user.activities.order(created_at: :desc).limit(20)

      # Orders
      @orders = @user.orders.includes(:product).order(created_at: :desc).limit(10)

      # Downloads
      @downloads = @user.download_links.includes(:product).order(created_at: :desc).limit(10)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to super_admin_user_path(@user), notice: "User was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      # Prevent deleting yourself or another super admin
      if @user == current_user
        redirect_to super_admin_users_path, alert: "You cannot delete your own account."
      elsif @user.super_admin?
        redirect_to super_admin_users_path, alert: "Super admin accounts cannot be deleted."
      else
        @user.destroy
        redirect_to super_admin_users_path, notice: "User was successfully deleted."
      end
    end

    def impersonate
      # Store the super admin's ID to be able to revert
      session[:admin_id] = current_user.id

      # Sign in as the impersonated user
      sign_in(@user, bypass: true)

      redirect_to root_path, notice: "You are now impersonating #{@user.email}. Click 'Stop Impersonation' to return to your account."
    end

    def stop_impersonation
      if session[:admin_id].present?
        # Get the original admin user
        admin = User.find_by(id: session[:admin_id])

        if admin.present?
          # Sign back in as the admin
          sign_in(admin, bypass: true)
          session.delete(:admin_id)
          redirect_to super_admin_users_path, notice: "You have stopped impersonating and returned to your account."
        else
          redirect_to root_path, alert: "Could not find the original admin account."
        end
      else
        redirect_to root_path, alert: "You are not currently impersonating a user."
      end
    end

    def toggle_admin
      return redirect_to super_admin_users_path, alert: "You cannot modify super admin privileges." if @user.super_admin?

      # Toggle admin status
      @user.update(admin: !@user.admin)

      redirect_to super_admin_user_path(@user), notice: "User admin status updated to #{@user.admin? ? 'Admin' : 'Regular User'}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :admin, :active, :profile_picture, :remove_profile_picture)
    end
  end
end
