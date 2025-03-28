require "test_helper"

class SellerShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller = sellers(:one)
  end

  test "should show seller profile" do
    begin
      get seller_path(@seller)
      assert_response :success
    rescue => e
      puts "Error in seller show test: #{e.message}"
      raise
    end
  end
end
