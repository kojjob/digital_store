require "test_helper"

class SellerShowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @seller = sellers(:one)

    # Debug logging to verify seller exists
    puts "Test Setup: Seller ID = #{@seller.id}"
    puts "Seller exists in DB? #{Seller.exists?(@seller.id)}"
    puts "Seller business name: #{@seller.business_name}"
    puts "Seller user: #{@seller.user.email}"
  end

  test "should show seller profile without login" do
    # Make GET request to seller show page
    get seller_path(@seller)

    # Debug response
    puts "Response status: #{response.status}"

    # Assert successful response
    assert_response :success

    # Check content
    assert_select "h1", text: "Showing seller"
    assert_select "#seller_#{@seller.id}" # Check for seller div with correct DOM ID
  end
end
