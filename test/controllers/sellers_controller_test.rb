require "test_helper"

class SellersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:valid_user)
    @seller = sellers(:one)
    @user_with_seller = users(:one)
    @admin = users(:admin_user)
  end

  test "should get index" do
    get sellers_url
    assert_response :success
  end

  test "should get new when logged in" do
    sign_in @user
    get become_seller_path
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get become_seller_path
    assert_redirected_to new_user_session_path
  end

  test "should show seller profile" do
    get seller_path(@seller)
    assert_response :success
  end

  test "should redirect to sellers_path when seller not found" do
    get seller_path(id: 9999)
    assert_redirected_to sellers_path
    assert_equal "Seller not found.", flash[:alert]
  end

  test "seller dashboard requires authentication" do
    get sellers_dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "seller dashboard requires seller account" do
    sign_in @user  # User without seller account
    get sellers_dashboard_path
    assert_redirected_to become_seller_path
    assert_equal "You need to register as a seller first.", flash[:alert]
  end

  test "seller with account can access dashboard" do
    sign_in @user_with_seller  # User with a seller account
    get sellers_dashboard_path
    assert_response :success
  end

  test "should get edit when seller owner" do
    sign_in @user_with_seller
    get edit_seller_path(@seller)
    assert_response :success
  end

  test "should redirect edit when not seller owner" do
    sign_in @user
    get edit_seller_path(@seller)
    assert_redirected_to sellers_path
    assert_equal "You don't have permission to perform this action.", flash[:alert]
  end

  test "admin can edit any seller" do
    sign_in @admin
    get edit_seller_path(@seller)
    assert_response :success
  end

  test "should update seller when owner" do
    sign_in @user_with_seller
    patch seller_path(@seller), params: { seller: { business_name: "Updated Business Name" } }
    assert_redirected_to seller_path(@seller)
    @seller.reload
    assert_equal "Updated Business Name", @seller.business_name
  end

  test "should redirect update when not seller owner" do
    sign_in @user
    original_name = @seller.business_name
    patch seller_path(@seller), params: { seller: { business_name: "Hacked Business Name" } }
    assert_redirected_to sellers_path
    @seller.reload
    assert_equal original_name, @seller.business_name
  end

  test "admin can update any seller" do
    sign_in @admin
    patch seller_path(@seller), params: { seller: { business_name: "Admin Updated Name" } }
    assert_redirected_to seller_path(@seller)
    @seller.reload
    assert_equal "Admin Updated Name", @seller.business_name
  end

  test "seller products page requires seller account" do
    sign_in @user
    get sellers_products_path
    assert_redirected_to become_seller_path
  end

  test "seller with account can access products page" do
    sign_in @user_with_seller
    get sellers_products_path
    assert_response :success
  end

  test "should get new product page when seller" do
    sign_in @user_with_seller
    get new_sellers_product_path
    assert_response :success
  end

  test "should redirect new product when not seller" do
    sign_in @user
    get new_sellers_product_path
    assert_redirected_to become_seller_path
  end
end
