# frozen_string_literal: true

module Admin
  module Security
    module PaymentDashboardHelper
      # Get chart colors for consistent styling
      def chart_colors
        [
          "#4e73df", "#1cc88a", "#36b9cc", "#f6c23e", "#e74a3b", "#5a5c69",
          "#6610f2", "#fd7e14", "#20c9a6", "#858796"
        ]
      end

      # CSS class for event rows based on event type
      def row_class_for_event(event_type)
        case event_type
        when "payment_successful", "refund_successful"
          "table-success"
        when "payment_failed", "refund_failed"
          "table-warning"
        when "signature_invalid"
          "table-danger"
        else
          ""
        end
      end

      # CSS class for modal headers based on event type
      def modal_header_class_for_event(event_type)
        case event_type
        when "payment_successful", "refund_successful"
          "bg-success"
        when "payment_failed", "refund_failed"
          "bg-warning"
        when "signature_invalid"
          "bg-danger"
        else
          "bg-primary"
        end
      end

      # Extract IP address from metadata hash (handles different formats)
      def extract_ip_from_metadata(metadata)
        return nil unless metadata.is_a?(Hash)

        # Try different common paths where IP might be stored
        ip = metadata.dig("request", "ip")
        ip ||= metadata.dig("ip")
        ip ||= metadata.dig("client_ip")
        ip ||= metadata.dig("remote_ip")
        ip ||= metadata.dig("headers", "X-Forwarded-For")

        # If still not found, try to search keys that might contain 'ip'
        if ip.nil?
          ip_keys = metadata.keys.select { |k| k.to_s.downcase.include?("ip") }
          ip = metadata[ip_keys.first] if ip_keys.any?
        end

        ip
      end
    end
  end
end
