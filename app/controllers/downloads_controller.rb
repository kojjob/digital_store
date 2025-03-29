# frozen_string_literal: true

class DownloadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_download_link, only: [ :show ]

  def index
    @download_links = current_user.download_links
                                 .includes(:product)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(10)
  end

  def show
    # Check if the download link is valid
    unless @download_link.valid_for_download?
      handle_invalid_download
      return
    end

    # Increment the download count
    @download_link.increment_download_count!

    # Record the download activity
    record_download_activity

    # Check if the product has a digital file attached
    unless @download_link.product.digital_file.attached?
      redirect_to downloads_path, alert: "This product does not have a digital file attached."
      return
    end

    # Serve the file for download
    respond_to do |format|
      format.html { redirect_to rails_blob_path(@download_link.product.digital_file, disposition: "attachment") }
      format.json { render json: { download_url: rails_blob_path(@download_link.product.digital_file, disposition: "attachment") } }
    end
  end

  private

  def set_download_link
    @download_link = current_user.download_links.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to downloads_path, alert: "Invalid download link."
  end

  def handle_invalid_download
    if @download_link.expired?
      redirect_to downloads_path, alert: "This download link has expired."
    elsif @download_link.download_limit_reached?
      redirect_to downloads_path, alert: "You have reached the download limit for this file."
    else
      redirect_to downloads_path, alert: "This download link is no longer valid."
    end
  end

  def record_download_activity
    current_user.record_activity(
      "download",
      title: "Downloaded #{@download_link.product.name}",
      description: "You downloaded #{@download_link.product.name}",
      reference: @download_link.product
    )
  end
end
