require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:valid_user)
  end

  test "full_name returns combined first and last name" do
    assert_equal "John Doe", @user.full_name
  end

  test "full_name handles missing last name" do
    @user.last_name = nil
    assert_equal "John", @user.full_name
  end

  test "seller? returns true for users with seller association" do
    @user_with_seller = users(:one)
    assert @user_with_seller.seller?
  end

  test "seller? returns false for users without seller association" do
    assert_not @user.seller?
  end

  test "buyer? returns true for non-sellers" do
    assert @user.buyer?
  end

  test "buyer? returns false for sellers" do
    @user_with_seller = users(:one)
    assert_not @user_with_seller.buyer?
  end
end
