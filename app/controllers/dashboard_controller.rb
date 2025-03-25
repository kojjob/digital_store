class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Add any dashboard data loading here
  end
end
