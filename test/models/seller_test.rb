require "test_helper"

class SellerTest < ActiveSupport::TestCase
  setup do
    # Use fixture data instead of creating new records
    @user = users(:buyer) # Use an existing user without a seller
    @seller = Seller.new(
      user: @user,
      business_name: "Test Business"
    )
  end

  test "should be valid with valid attributes" do
    assert @seller.valid?, "Seller wasn't valid. Errors: #{@seller.errors.full_messages}"
  end

  test "should not be valid without a user" do
    @seller.user = nil
    assert_not @seller.valid?
  end

  test "store_name returns business name when available" do
    @seller.business_name = "Test Store"
    assert_equal "Test Store", @seller.store_name
  end

  test "store_name falls back to user's first name with Store" do
    @seller.business_name = nil
    assert_equal "Regular's Store", @seller.store_name # 'Regular' is the first_name of the buyer user
  end

  test "verified? returns verification status" do
    @seller.verified = true
    assert @seller.verified?

    @seller.verified = false
    assert_not @seller.verified?
  end

  test "has methods for sales metrics" do
    # Simple tests to verify methods exist
    assert_respond_to @seller, :total_sales
    assert_respond_to @seller, :total_orders
    assert_respond_to @seller, :total_customers
    assert_respond_to @seller, :average_rating
    assert_respond_to @seller, :response_rate
  end
end
