require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = Category.new(
      name: "Test Category",
      description: "This is a test category",
      slug: "test-category-#{Time.now.to_i}",
      position: 1,
      visible: true
    )
  end

  test "should be valid with valid attributes" do
    assert @category.valid?
  end

  test "should not be valid without a name" do
    @category.name = nil
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "should automatically generate a slug from name when slug is blank" do
    @category.slug = nil
    @category.valid?
    assert_equal "test-category", @category.slug
  end

  test "should use existing slug if provided" do
    custom_slug = "custom-slug-#{Time.now.to_i}"
    @category.slug = custom_slug
    @category.valid?
    assert_equal custom_slug, @category.slug
  end
end
