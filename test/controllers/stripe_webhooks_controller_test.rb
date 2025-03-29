# frozen_string_literal: true

require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)

    # Create webhook payload to test
    @payload = {
      id: "evt_test_webhook",
      type: "checkout.session.completed",
      data: {
        object: {
          id: @order.payment_id,
          payment_status: "paid"
        }
      }
    }.to_json

    # Mock signature
    @signature = "test_signature"
  end

  test "should reject webhooks without signature" do
    post stripe_webhooks_path, params: @payload, headers: {
      "CONTENT_TYPE" => "application/json"
    }

    assert_response :bad_request
    assert_equal "error", JSON.parse(response.body)["status"]
  end

  test "should process valid webhooks" do
    # Mock StripeService webhook handler
    result = { status: 200 }

    StripeService.stub(:handle_webhook, result) do
      post stripe_webhooks_path, params: @payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "HTTP_STRIPE_SIGNATURE" => @signature
      }

      assert_response :success
      assert_equal "success", JSON.parse(response.body)["status"]
    end
  end

  test "should handle webhook errors" do
    # Mock StripeService webhook handler with error
    result = { status: 400, error: "Invalid payload" }

    StripeService.stub(:handle_webhook, result) do
      post stripe_webhooks_path, params: @payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "HTTP_STRIPE_SIGNATURE" => @signature
      }

      assert_response :bad_request
      assert_equal "error", JSON.parse(response.body)["status"]
    end
  end
end
