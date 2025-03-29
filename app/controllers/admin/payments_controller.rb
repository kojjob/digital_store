# frozen_string_literal: true

module Admin
  class PaymentsController < AdminController
    before_action :set_order, only: [ :show, :update, :resend_receipt, :generate_download, :reset_download, :email_download, :revoke_download ]

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

      # Load payment audit logs for this order
      @audit_logs = PaymentAuditLog.where(order: @order).order(created_at: :desc)

      # Set active tab (default to details if not specified)
      @active_tab = params[:tab] || "details"
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

    def resend_receipt
      recipient = params[:recipient] || @order.user.email
      message = params[:message]

      # Send the receipt email
      OrderMailer.payment_confirmation(@order, recipient, message).deliver_later

      redirect_to admin_payment_path(@order), notice: "Receipt sent to #{recipient}."
    end

    def generate_download
      if @order.product.digital_file.attached?
        # Check if a download link already exists
        if DownloadLink.exists?(order: @order)
          redirect_to admin_payment_path(@order), alert: "Download link already exists for this order."
          return
        end

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

        redirect_to admin_payment_path(@order, tab: "downloads"), notice: "Download link generated successfully."
      else
        redirect_to admin_payment_path(@order), alert: "This product doesn't have a digital file attached."
      end
    end

    def reset_download
      link_id = params[:link_id]
      download_link = DownloadLink.find_by(id: link_id, order: @order)

      if download_link
        download_link.update(
          download_count: 0,
          expires_at: 30.days.from_now
        )

        redirect_to admin_payment_path(@order, tab: "downloads"), notice: "Download link reset successfully."
      else
        redirect_to admin_payment_path(@order), alert: "Download link not found."
      end
    end

    def email_download
      link_id = params[:link_id]
      download_link = DownloadLink.find_by(id: link_id, order: @order)

      if download_link
        # Send the download link email
        OrderMailer.download_ready(download_link).deliver_later

        redirect_to admin_payment_path(@order, tab: "downloads"), notice: "Download link email sent to #{@order.user.email}."
      else
        redirect_to admin_payment_path(@order), alert: "Download link not found."
      end
    end

    def revoke_download
      link_id = params[:link_id]
      download_link = DownloadLink.find_by(id: link_id, order: @order)

      if download_link
        download_link.destroy

        redirect_to admin_payment_path(@order, tab: "downloads"), notice: "Download link revoked successfully."
      else
        redirect_to admin_payment_path(@order), alert: "Download link not found."
      end
    end

    def export_audit_log
      order_id = params[:id] || params[:order_id]
      order = Order.find(order_id)
      @audit_logs = PaymentAuditLog.where(order: order).order(created_at: :desc)

      respond_to do |format|
        format.csv do
          headers["Content-Disposition"] = "attachment; filename=\"audit_log_order_#{order.id}.csv\""
          headers["Content-Type"] = "text/csv"

          # Generate CSV data without using the CSV library
          csv_data = generate_csv_data(@audit_logs)
          render plain: csv_data
        end
      end
    end

    def generate_csv_data(logs)
      # CSV headers
      headers = [ "Timestamp", "Event Type", "Payment Processor", "Amount", "Transaction ID", "Metadata" ]

      # Generate header row
      csv_data = headers.join(",") + "\n"

      # Generate data rows
      logs.each do |log|
        row = [
          log.created_at,
          log.event_type,
          log.payment_processor,
          log.amount,
          log.transaction_id,
          log.metadata.to_s.gsub(",", " ")
        ]

        # Escape any fields with commas by enclosing in quotes
        escaped_row = row.map do |field|
          field = field.to_s
          if field.include?(",") || field.include?("\n") || field.include?('"')
            '"' + field.gsub('"', '""') + '"'
          else
            field
          end
        end

        csv_data += escaped_row.join(",") + "\n"
      end

      csv_data
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
