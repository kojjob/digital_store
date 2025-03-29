# frozen_string_literal: true

module Admin
  class DownloadsController < AdminController
    before_action :set_download_link, only: [ :show, :edit, :update, :destroy, :regenerate ]

    def index
      @download_links = DownloadLink.includes(:user, :product, :order)
                                   .order(created_at: :desc)
                                   .page(params[:page])
                                   .per(20)

      # Apply filters if provided
      if params[:filter].present?
        @filter = params[:filter]
        case @filter
        when "active"
          @download_links = @download_links.active
        when "expired"
          @download_links = @download_links.where("expires_at < ?", Time.current)
        when "limit_reached"
          @download_links = @download_links.where("download_count >= download_limit AND download_limit > 0")
        when "inactive"
          @download_links = @download_links.where(active: false)
        end
      end

      # Apply search if provided
      if params[:search].present?
        @search = params[:search].strip
        @download_links = @download_links.joins(:user, :product)
                                       .where("users.email LIKE ? OR products.name LIKE ? OR download_links.token LIKE ?",
                                             "%#{@search}%", "%#{@search}%", "%#{@search}%")
      end
    end

    def show
      # Load download activity for this link
      @download_activities = UserActivity.where(activity_type: "download")
                                        .where("description LIKE ?", "%#{@download_link.product.name}%")
                                        .order(created_at: :desc)
                                        .limit(10)
    end

    def edit
    end

    def update
      if @download_link.update(download_link_params)
        redirect_to admin_download_path(@download_link), notice: "Download link was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @download_link.destroy
      redirect_to admin_downloads_path, notice: "Download link was successfully deleted."
    end

    def regenerate
      new_expiry = params[:expires_at].present? ? Time.parse(params[:expires_at]) : 7.days.from_now

      @download_link.regenerate!(new_expiry)

      # Notify the user about the regenerated download link
      OrderMailer.download_ready(@download_link).deliver_later

      redirect_to admin_download_path(@download_link), notice: "Download link was successfully regenerated and the user has been notified."
    end

    private

    def set_download_link
      @download_link = DownloadLink.find(params[:id])
    end

    def download_link_params
      params.require(:download_link).permit(:expires_at, :download_limit, :active)
    end
  end
end
