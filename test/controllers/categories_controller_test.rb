require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @category = categories(:one)
    @admin = users(:admin_user)
    @regular_user = users(:valid_user)
  end

  # Basic actions that don't require authentication
  test "should get index" do
    get categories_url
    assert_response :success
    assert_not_nil assigns(:categories)
    assert_not_nil assigns(:nav_categories)
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:nav_categories)
    assert_not_nil assigns(:products)
    assert_not_nil assigns(:subcategories)
  end

  # Authentication tests
  test "should redirect admin actions when not signed in" do
    get new_category_url
    assert_redirected_to new_user_session_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
  end

  # Admin role tests - minimal subset
  test "should allow admin to see new category form" do
    sign_in @admin
    get new_category_url
    assert_response :success
  end

  test "should redirect new when not admin" do
    sign_in @regular_user
    get new_category_url
    assert_redirected_to root_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
  end

  # Create tests
  test "should allow admin to create category" do
    sign_in @admin
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: "New Category", description: "New description" } }
    end
    assert_redirected_to category_url(Category.last)
  end

  test "should redirect create when not admin" do
    sign_in @regular_user
    assert_no_difference("Category.count") do
      post categories_url, params: { category: { name: "New Category", description: "New description" } }
    end
    assert_redirected_to root_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
  end

  # Edit tests
  test "should allow admin to get edit" do
    sign_in @admin
    get edit_category_url(@category)
    assert_response :success
  end

  test "should redirect edit when not admin" do
    sign_in @regular_user
    get edit_category_url(@category)
    assert_redirected_to root_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
  end

  # Update tests
  test "should allow admin to update category" do
    sign_in @admin
    patch category_url(@category), params: { category: { name: "Updated Name" } }
    assert_redirected_to category_url(@category)
    @category.reload
    assert_equal "Updated Name", @category.name
  end

  test "should redirect update when not admin" do
    sign_in @regular_user
    original_name = @category.name
    patch category_url(@category), params: { category: { name: "Hacked Name" } }
    assert_redirected_to root_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
    @category.reload
    assert_equal original_name, @category.name
  end

  # Destroy tests
  test "should allow admin to destroy category" do
    sign_in @admin
    assert_difference("Category.count", -1) do
      delete category_url(categories(:two))
    end
    assert_redirected_to categories_path
  end

  test "should redirect destroy when not admin" do
    sign_in @regular_user
    assert_no_difference("Category.count") do
      delete category_url(@category)
    end
    assert_redirected_to root_path
    assert_equal "You must be an administrator to perform this action.", flash[:alert]
  end
end
