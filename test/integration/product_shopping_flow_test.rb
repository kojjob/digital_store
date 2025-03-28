require "test_helper"

class ProductShoppingFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @product = products(:one)
    @user = users(:valid_user)
  end

  test "can view product index" do
    get products_path
    assert_response :success
  end

  test "can view product details" do
    get product_path(@product)
    assert_response :success
  end

  test "guest redirected to login when accessing checkout" do
    get checkout_path
    assert_redirected_to new_user_session_path
  end
end
