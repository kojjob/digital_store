# frozen_string_literal: true

module Admin
  class PaymentsController < AdminController
    before_action :set_order, only: [ :show, :update ]

    def index
      @orders = Order.includes(:user, :product)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(20)

      # Apply payment processor filter if provided
      if params[:payment_processor].present?
        @payment_processor = params[:payment_processor]
        @orders = @orders.where(payment_processor: @payment_processor)
      end

      # Apply status filter if provided
      if params[:status].present?
        @status = params[:status]
        @orders = @orders.where(status: @status)
      end

      # Apply search if provided
      if params[:search].present?
        @search = params[:search].strip
        @orders = @orders.joins(:user, :product)
                        .where("users.email LIKE ? OR products.name LIKE ? OR orders.payment_id LIKE ?",
                              "%#{@search}%", "%#{@search}%", "%#{@search}%")
      end

      # Get summary statistics
      @total_revenue = Order.where(status: "paid").sum(:total_amount)
      @successful_count = Order.where(status: "paid").count
      @pending_count = Order.where(status: "pending").count
      @cancelled_count = Order.where(status: "cancelled").count

      # Get payment processor breakdown
      @payment_processors = Order.group(:payment_processor).count
    end

    def show
      # If this is a digital product, load associated download links
      if @order.product.is_digital?
        @download_links = DownloadLink.where(order: @order).order(created_at: :desc)
      end
    end

    def update
      # Allow manual override of payment status for special cases
      if @order.update(order_params)
        # If the order was manually marked as paid and it's a digital product
        if @order.status == "paid" && @order.product.is_digital? && @order.product.digital_file.attached?
          # Check if a download link already exists
          unless DownloadLink.exists?(order: @order)
            # Create a download link
            download_link = DownloadLink.create!(
              user: @order.user,
              product: @order.product,
              order: @order,
              expires_at: 30.days.from_now,
              download_limit: 5,
              file_name: @order.product.digital_file.filename.to_s,
              file_size: @order.product.digital_file.byte_size,
              content_type: @order.product.digital_file.content_type
            )

            # Send notification
            OrderMailer.download_ready(download_link).deliver_later
          end

          # Send payment confirmation
          OrderMailer.payment_confirmation(@order).deliver_later
        end

        redirect_to admin_payment_path(@order), notice: "Order was successfully updated."
      else
        render :show
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :payment_status, :notes)
    end
  end
end
