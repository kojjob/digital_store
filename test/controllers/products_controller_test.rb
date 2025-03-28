require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @product = products(:one)
    @user = users(:valid_user)
    @seller_user = users(:one)  # This user has a seller association
    @admin = users(:admin_user)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get show" do
    get product_url(@product)
    assert_response :success
  end

  test "should handle non-existent product" do
    get product_url(id: 9999)
    assert_redirected_to products_path
    assert_equal "Product not found", flash[:alert]
  end

  test "should get new when logged in as seller" do
    sign_in @seller_user
    get new_product_url
    assert_response :success
  end

  test "should redirect new when logged in but not a seller" do
    sign_in @user
    get new_product_url
    assert_redirected_to become_seller_path
  end

  test "should redirect new when not logged in" do
    get new_product_url
    assert_redirected_to new_user_session_path
  end

  test "should create product when logged in as seller" do
    sign_in @seller_user
    assert_difference("Product.count") do
      post products_url, params: {
        product: {
          name: "New Test Product",
          description: "This is a test product description that's long enough to pass validation.",
          price: 29.99,
          category_id: @product.category_id
        }
      }
    end
    assert_redirected_to product_url(Product.last)
  end

  test "should redirect create when not logged in" do
    assert_no_difference("Product.count") do
      post products_url, params: {
        product: {
          name: "New Test Product",
          description: "This is a test product description.",
          price: 29.99,
          category_id: @product.category_id
        }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "should get edit when seller owns product" do
    sign_in @seller_user
    get edit_product_url(@product)
    assert_response :success
  end

  test "should redirect edit when not product owner" do
    sign_in @user
    get edit_product_url(@product)
    assert_redirected_to products_path
  end

  test "should update product when seller owns it" do
    sign_in @seller_user
    patch product_url(@product), params: { product: { name: "Updated Product Name" } }
    assert_redirected_to product_url(@product)
    @product.reload
    assert_equal "Updated Product Name", @product.name
  end

  test "should redirect update when not product owner" do
    sign_in @user
    original_name = @product.name
    patch product_url(@product), params: { product: { name: "Hacked Product Name" } }
    assert_redirected_to products_path
    @product.reload
    assert_equal original_name, @product.name
  end

  test "should destroy product when seller owns it" do
    sign_in @seller_user
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end
    assert_redirected_to products_path
  end

  test "should redirect destroy when not product owner" do
    sign_in @user
    assert_no_difference("Product.count") do
      delete product_url(@product)
    end
    assert_redirected_to products_path
  end

  test "admin can edit any product" do
    sign_in @admin
    get edit_product_url(@product)
    assert_response :success
  end

  test "admin can update any product" do
    sign_in @admin
    patch product_url(@product), params: { product: { name: "Admin Updated Name" } }
    assert_redirected_to product_url(@product)
    @product.reload
    assert_equal "Admin Updated Name", @product.name
  end

  test "admin can destroy any product" do
    sign_in @admin
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end
    assert_redirected_to products_path
  end
end
