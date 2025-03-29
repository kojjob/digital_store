# frozen_string_literal: true

module Admin
  module PaymentsHelper
    def log_event_class(event_type)
      case event_type
      when "payment_successful", "refund_successful"
        "table-success"
      when "payment_failed", "refund_failed", "signature_invalid"
        "table-danger"
      when "payment_pending"
        "table-warning"
      else
        ""
      end
    end

    def payment_status_badge(status)
      case status
      when "paid"
        content_tag(:span, "Paid", class: "badge badge-success")
      when "pending"
        content_tag(:span, "Pending", class: "badge badge-warning")
      when "failed"
        content_tag(:span, "Failed", class: "badge badge-danger")
      when "cancelled"
        content_tag(:span, "Cancelled", class: "badge badge-secondary")
      when "refunded"
        content_tag(:span, "Refunded", class: "badge badge-info")
      else
        content_tag(:span, status.titleize, class: "badge badge-primary")
      end
    end
  end
end
