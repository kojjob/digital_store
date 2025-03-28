require "test_helper"

class SellerManagementFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller_user = users(:one)
    @seller = sellers(:one)
    @non_seller_user = users(:valid_user)
  end

  test "users can view become a seller page" do
    sign_in @non_seller_user
    get become_seller_path
    assert_response :success
    assert_select "h1", /Become a Seller/i
  end

  test "seller can view dashboard" do
    sign_in @seller_user
    get sellers_dashboard_path
    assert_response :success
    assert_select "h1", /Seller Dashboard/i
  end

  test "non-seller is redirected to become a seller page" do
    sign_in @non_seller_user
    get sellers_dashboard_path
    assert_redirected_to become_seller_path
    assert_equal "You need to register as a seller first.", flash[:alert]
  end

  test "unauthenticated user is redirected to login when trying to access seller dashboard" do
    get sellers_dashboard_path
    assert_redirected_to new_user_session_path
  end
end
