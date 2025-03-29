# frozen_string_literal: true

require "test_helper"

class MomoWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)

    # Create webhook payload to test
    @payload = {
      transaction_reference: @order.payment_id,
      status: "successful",
      provider: "mtn",
      phone_number: "0241234567",
      amount: @order.total_amount
    }.to_json

    # Mock signature
    @signature = "test_signature"
  end

  test "should reject webhooks without signature" do
    post momo_webhook_path(provider: "mtn"), params: @payload, headers: {
      "CONTENT_TYPE" => "application/json"
    }

    assert_response :bad_request
    assert_equal "error", JSON.parse(response.body)["status"]
  end

  test "should reject webhooks with invalid provider" do
    post momo_webhook_path(provider: "invalid"), params: @payload, headers: {
      "CONTENT_TYPE" => "application/json",
      "X-Momo-Signature" => @signature
    }

    assert_response :bad_request
    assert_equal "error", JSON.parse(response.body)["status"]
  end

  test "should process valid webhooks" do
    # Mock MomoService webhook handler
    result = { status: 200 }

    MomoService.stub(:process_webhook, result) do
      post momo_webhook_path(provider: "mtn"), params: @payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Momo-Signature" => @signature
      }

      assert_response :success
      assert_equal "success", JSON.parse(response.body)["status"]
    end
  end

  test "should handle webhook errors" do
    # Mock MomoService webhook handler with error
    result = { status: 400, error: "Invalid payload" }

    MomoService.stub(:process_webhook, result) do
      post momo_webhook_path(provider: "mtn"), params: @payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Momo-Signature" => @signature
      }

      assert_response :bad_request
      assert_equal "error", JSON.parse(response.body)["status"]
    end
  end
end
