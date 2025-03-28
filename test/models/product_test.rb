require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @category = categories(:one)
    @seller = sellers(:one)
    @product = Product.new(
      name: "Test Product",
      description: "This is a test product with a detailed description for testing purposes.",
      price: 19.99,
      category: @category,
      seller: @seller
    )
  end

  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should not be valid without a name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "should not be valid with a short name" do
    @product.name = "AB"
    assert_not @product.valid?
    assert_includes @product.errors[:name], "is too short (minimum is 3 characters)"
  end

  test "should not be valid without a description" do
    @product.description = nil
    assert_not @product.valid?
    assert_includes @product.errors[:description], "can't be blank"
  end

  test "should not be valid without a price" do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "can't be blank"
  end

  test "should not be valid with a negative price" do
    @product.price = -1.00
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than or equal to 0"
  end

  test "should not be valid without a seller" do
    @product.seller = nil
    assert_not @product.valid?
    assert_includes @product.errors[:seller_id], "can't be blank"
  end

  test "should not be valid without a category" do
    @product.category = nil
    assert_not @product.valid?
    assert_includes @product.errors[:category_id], "can't be blank"
  end
end
