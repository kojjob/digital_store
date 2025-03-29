# frozen_string_literal: true

module Admin
  module Security
    class PaymentDashboardController < AdminController
      def index
        # Date range for filtering (default to last 30 days)
        @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
        @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

        # Base query for the selected date range
        base_query = PaymentAuditLog.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)

        # Security events
        @security_events = base_query.where(event_type: [ "signature_invalid" ])
                                    .order(created_at: :desc)
                                    .limit(20)

        # Security summary stats
        @security_summary = {
          total_signature_failures: base_query.where(event_type: "signature_invalid").count,
          by_processor: base_query.where(event_type: "signature_invalid")
                                 .group(:payment_processor)
                                 .count
        }

        # Payment processing errors
        @payment_errors = base_query.where(event_type: "payment_failed")
                                  .order(created_at: :desc)
                                  .limit(20)

        # Payment processor success rates
        successful_payments = base_query.where(event_type: "payment_successful")
                                      .group(:payment_processor)
                                      .count

        failed_payments = base_query.where(event_type: "payment_failed")
                                  .group(:payment_processor)
                                  .count

        @processor_stats = {}

        # Calculate success rate for each processor
        (successful_payments.keys | failed_payments.keys).each do |processor|
          success_count = successful_payments[processor] || 0
          fail_count = failed_payments[processor] || 0
          total = success_count + fail_count

          @processor_stats[processor] = {
            success: success_count,
            failed: fail_count,
            total: total,
            success_rate: total > 0 ? (success_count.to_f / total * 100).round(1) : 0
          }
        end

        # Unusual patterns - detect IP addresses with multiple signature failures
        @suspicious_ips = []

        signature_failures = base_query.where(event_type: "signature_invalid")

        if signature_failures.any?
          # Extract IPs from metadata and count occurrences
          ip_counts = {}

          signature_failures.each do |log|
            begin
              metadata = log.metadata_hash
              ip = metadata.dig("request", "ip") || metadata.dig("ip")

              if ip.present?
                ip_counts[ip] ||= 0
                ip_counts[ip] += 1
              end
            rescue => e
              Rails.logger.error("Error processing metadata for log ##{log.id}: #{e.message}")
            end
          end

          # Filter for IPs with multiple failures
          @suspicious_ips = ip_counts.select { |_ip, count| count > 1 }
                                     .sort_by { |_ip, count| -count }
                                     .map { |ip, count| { ip: ip, count: count } }
        end

        # Daily trends
        @daily_stats = base_query.group("DATE(created_at)")
                               .group(:event_type)
                               .count
                               .transform_keys { |date, event| [ date, event ] }

        # Format for charting
        @chart_data = (@start_date..@end_date).map do |date|
          {
            date: date.strftime("%Y-%m-%d"),
            successful: @daily_stats[[ date, "payment_successful" ]] || 0,
            failed: @daily_stats[[ date, "payment_failed" ]] || 0,
            security: @daily_stats[[ date, "signature_invalid" ]] || 0
          }
        end
      end

      def recent_events
        @events = PaymentAuditLog.order(created_at: :desc).limit(100)

        respond_to do |format|
          format.html
          format.csv do
            headers["Content-Disposition"] = "attachment; filename=\"payment_security_events.csv\""
            headers["Content-Type"] = "text/csv"

            # Generate CSV data without using the CSV library
            csv_data = generate_csv_data(@events)
            render plain: csv_data
          end
        end
      end

      private

      def generate_csv_data(events)
        # CSV headers
        headers = [ "ID", "Timestamp", "Event Type", "Payment Processor", "Amount", "Transaction ID", "Order ID", "User ID", "Metadata" ]

        # Generate header row
        csv_data = headers.join(",") + "\n"

        # Generate data rows
        events.each do |event|
          row = [
            event.id,
            event.created_at,
            event.event_type,
            event.payment_processor,
            event.amount,
            event.transaction_id,
            event.order_id,
            event.user_id,
            event.metadata.to_s.gsub(",", " ")
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
    end
  end
end
