require "application_system_test_case"

class SellersTest < ApplicationSystemTestCase
  setup do
    @seller = sellers(:one)
  end

  test "visiting the index" do
    visit sellers_url
    assert_selector "h1", text: "Sellers"
  end

  test "should create seller" do
    visit sellers_url
    click_on "New seller"

    fill_in "Acceptance rate", with: @seller.acceptance_rate
    fill_in "Average response time", with: @seller.average_response_time
    fill_in "Bank account details", with: @seller.bank_account_details
    fill_in "Business name", with: @seller.business_name
    fill_in "Commission rate", with: @seller.commission_rate
    fill_in "Country", with: @seller.country
    fill_in "Description", with: @seller.description
    fill_in "Location", with: @seller.location
    fill_in "Mobile money details", with: @seller.mobile_money_details
    fill_in "Phone number", with: @seller.phone_number
    fill_in "User", with: @seller.user_id
    check "Verified" if @seller.verified
    click_on "Create Seller"

    assert_text "Seller was successfully created"
    click_on "Back"
  end

  test "should update Seller" do
    visit seller_url(@seller)
    click_on "Edit this seller", match: :first

    fill_in "Acceptance rate", with: @seller.acceptance_rate
    fill_in "Average response time", with: @seller.average_response_time
    fill_in "Bank account details", with: @seller.bank_account_details
    fill_in "Business name", with: @seller.business_name
    fill_in "Commission rate", with: @seller.commission_rate
    fill_in "Country", with: @seller.country
    fill_in "Description", with: @seller.description
    fill_in "Location", with: @seller.location
    fill_in "Mobile money details", with: @seller.mobile_money_details
    fill_in "Phone number", with: @seller.phone_number
    fill_in "User", with: @seller.user_id
    check "Verified" if @seller.verified
    click_on "Update Seller"

    assert_text "Seller was successfully updated"
    click_on "Back"
  end

  test "should destroy Seller" do
    visit seller_url(@seller)
    accept_confirm { click_on "Destroy this seller", match: :first }

    assert_text "Seller was successfully destroyed"
  end
end
