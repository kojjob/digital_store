require "test_helper"

class Line28Test < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller = sellers(:one)
  end

  test "should show seller profile - specific test" do
    puts "Starting specific test for line 28 (show action)"
    puts "Seller ID: #{@seller.id}"
    puts "Seller exists?: #{Seller.exists?(@seller.id)}"

    begin
      get seller_path(@seller)
      puts "Response: #{response.status}"
      puts "Response body exists?: #{response.body.present?}"
      assert_response :success
    rescue => e
      puts "Exception occurred: #{e.class.name}"
      puts "Error message: #{e.message}"
      puts "Backtrace: #{e.backtrace[0..5].join("\n")}"
      raise e
    end
  end
end
