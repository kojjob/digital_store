# frozen_string_literal: true

# ChartsService
#
# Service class to generate chart data for dashboard visualizations.
# This follows the Service Object pattern to encapsulate data preparation
# logic for charts and graphs, keeping it separate from controllers and views.
class ChartsService
  # Generate revenue data for chart display
  #
  # @param seller [Seller] the seller to generate data for
  # @param period [Symbol] time period (:week, :month, :year)
  # @return [Hash] formatted chart data
  def self.revenue_chart_data(seller, period: :month)
    case period
    when :week
      daily_revenue_data(seller)
    when :month
      weekly_revenue_data(seller)
    when :year
      monthly_revenue_data(seller)
    else
      weekly_revenue_data(seller)
    end
  end

  # Generate orders data for chart display
  #
  # @param seller [Seller] the seller to generate data for
  # @param period [Symbol] time period (:week, :month, :year)
  # @return [Hash] formatted chart data
  def self.orders_chart_data(seller, period: :month)
    case period
    when :week
      daily_orders_data(seller)
    when :month
      weekly_orders_data(seller)
    when :year
      monthly_orders_data(seller)
    else
      weekly_orders_data(seller)
    end
  end

  # Generate product performance data
  #
  # @param seller [Seller] the seller to generate data for
  # @param limit [Integer] maximum number of products to include
  # @return [Hash] formatted chart data
  def self.product_performance_data(seller, limit: 5)
    products = seller.products.includes(:orders)
                    .sort_by { |p| p.orders.sum(&:total_amount) }
                    .reverse
                    .first(limit)

    {
      labels: products.map(&:name),
      datasets: [
        {
          label: "Revenue",
          data: products.map { |p| p.orders.sum(&:total_amount) },
          backgroundColor: "#4F46E5"
        },
        {
          label: "Orders",
          data: products.map { |p| p.orders.count },
          backgroundColor: "#10B981"
        }
      ]
    }
  end

  # Generate customer acquisition data
  #
  # @param seller [Seller] the seller to generate data for
  # @param months [Integer] number of months to include
  # @return [Hash] formatted chart data
  def self.customer_acquisition_data(seller, months: 6)
    end_date = Date.current.end_of_month
    start_date = (end_date - (months - 1).months).beginning_of_month

    # Group by month
    date_range = (start_date..end_date).select { |d| d.day == 1 }

    customer_counts = date_range.map do |date|
      month_start = date.beginning_of_month
      month_end = date.end_of_month

      # Count unique customers who made their first order in this month
      first_time_customers = Order.joins(product: :seller)
                                 .where(products: { seller_id: seller.id })
                                 .where(created_at: month_start..month_end)
                                 .select(:user_id)
                                 .distinct
                                 .count

      {
        month: date.strftime("%b %Y"),
        new_customers: first_time_customers
      }
    end

    {
      labels: customer_counts.map { |c| c[:month] },
      datasets: [
        {
          label: "New Customers",
          data: customer_counts.map { |c| c[:new_customers] },
          backgroundColor: "#8B5CF6",
          borderColor: "#7C3AED",
          borderWidth: 1
        }
      ]
    }
  end

  private

  # Generate daily revenue data
  def self.daily_revenue_data(seller)
    end_date = Date.current
    start_date = end_date - 6.days

    # Create a hash with all dates in range initialized to 0
    revenue_by_day = (start_date..end_date).each_with_object({}) do |date, hash|
      hash[date.strftime("%a")] = 0
    end

    # Fill in actual revenues
    seller.orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
          .group_by { |order| order.created_at.to_date.strftime("%a") }
          .each do |day, orders|
      revenue_by_day[day] = orders.sum(&:total_amount)
    end

    {
      labels: revenue_by_day.keys,
      datasets: [
        {
          label: "Revenue",
          data: revenue_by_day.values,
          backgroundColor: "#4F46E5",
          borderColor: "#4338CA",
          borderWidth: 1
        }
      ]
    }
  end

  # Generate weekly revenue data
  def self.weekly_revenue_data(seller)
    end_date = Date.current
    start_date = end_date - 4.weeks

    # Group by week
    revenue_by_week = {}

    current_date = start_date
    while current_date <= end_date
      week_start = current_date.beginning_of_week
      week_end = current_date.end_of_week
      week_label = "Week #{week_start.strftime('%d/%m')}"

      revenue_by_week[week_label] = seller.orders.where(created_at: week_start.beginning_of_day..week_end.end_of_day)
                                          .sum(:total_amount)

      current_date = week_end + 1.day
    end

    {
      labels: revenue_by_week.keys,
      datasets: [
        {
          label: "Revenue",
          data: revenue_by_week.values,
          backgroundColor: "#4F46E5",
          borderColor: "#4338CA",
          borderWidth: 1
        }
      ]
    }
  end

  # Generate monthly revenue data
  def self.monthly_revenue_data(seller)
    end_date = Date.current.end_of_month
    start_date = (end_date - 11.months).beginning_of_month

    # Group by month
    revenue_by_month = {}

    current_date = start_date
    while current_date <= end_date
      month_start = current_date.beginning_of_month
      month_end = current_date.end_of_month
      month_label = current_date.strftime("%b %Y")

      revenue_by_month[month_label] = seller.orders.where(created_at: month_start.beginning_of_day..month_end.end_of_day)
                                            .sum(:total_amount)

      current_date = month_end + 1.day
    end

    {
      labels: revenue_by_month.keys,
      datasets: [
        {
          label: "Revenue",
          data: revenue_by_month.values,
          backgroundColor: "#4F46E5",
          borderColor: "#4338CA",
          borderWidth: 1
        }
      ]
    }
  end

  # Generate daily orders data
  def self.daily_orders_data(seller)
    end_date = Date.current
    start_date = end_date - 6.days

    # Create a hash with all dates in range initialized to 0
    orders_by_day = (start_date..end_date).each_with_object({}) do |date, hash|
      hash[date.strftime("%a")] = 0
    end

    # Fill in actual order counts
    seller.orders.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
          .group_by { |order| order.created_at.to_date.strftime("%a") }
          .each do |day, orders|
      orders_by_day[day] = orders.count
    end

    {
      labels: orders_by_day.keys,
      datasets: [
        {
          label: "Orders",
          data: orders_by_day.values,
          backgroundColor: "#10B981",
          borderColor: "#059669",
          borderWidth: 1
        }
      ]
    }
  end

  # Generate weekly orders data
  def self.weekly_orders_data(seller)
    end_date = Date.current
    start_date = end_date - 4.weeks

    # Group by week
    orders_by_week = {}

    current_date = start_date
    while current_date <= end_date
      week_start = current_date.beginning_of_week
      week_end = current_date.end_of_week
      week_label = "Week #{week_start.strftime('%d/%m')}"

      orders_by_week[week_label] = seller.orders.where(created_at: week_start.beginning_of_day..week_end.end_of_day)
                                         .count

      current_date = week_end + 1.day
    end

    {
      labels: orders_by_week.keys,
      datasets: [
        {
          label: "Orders",
          data: orders_by_week.values,
          backgroundColor: "#10B981",
          borderColor: "#059669",
          borderWidth: 1
        }
      ]
    }
  end

  # Generate monthly orders data
  def self.monthly_orders_data(seller)
    end_date = Date.current.end_of_month
    start_date = (end_date - 11.months).beginning_of_month

    # Group by month
    orders_by_month = {}

    current_date = start_date
    while current_date <= end_date
      month_start = current_date.beginning_of_month
      month_end = current_date.end_of_month
      month_label = current_date.strftime("%b %Y")

      orders_by_month[month_label] = seller.orders.where(created_at: month_start.beginning_of_day..month_end.end_of_day)
                                           .count

      current_date = month_end + 1.day
    end

    {
      labels: orders_by_month.keys,
      datasets: [
        {
          label: "Orders",
          data: orders_by_month.values,
          backgroundColor: "#10B981",
          borderColor: "#059669",
          borderWidth: 1
        }
      ]
    }
  end
end
