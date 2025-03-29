# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  include WebhookHandling

  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    # Log the webhook receipt
    Rails.logger.info("Stripe webhook received. Request ID: #{request.request_id}")

    # Return error if signature header is missing
    unless signature
      log_and_respond("Signature header missing", :bad_request)
      return
    end

    # Create an audit log entry for the webhook receipt
    create_webhook_audit_log("stripe", payload)

    # Process the webhook
    result = StripeService.handle_webhook(payload, signature)

    if result[:status] == 200
      render json: { status: "success" }, status: :ok
    else
      # Don't expose detailed error messages in response
      render json: { status: "error" }, status: result[:status] || :bad_request

      # Log the actual error internally
      Rails.logger.error("Stripe webhook error: #{result[:error]}")
    end
  rescue => e
    # Log the error but return a generic response
    Rails.logger.error("Unexpected error in Stripe webhook processing: #{e.class.name} - #{e.message}")
    render json: { status: "error" }, status: :internal_server_error
  end

  private

  # Define the provider for the WebhookHandling concern
  def webhook_provider
    "stripe"
  end

  # Define the signature header for the WebhookHandling concern
  def webhook_signature_header
    "HTTP_STRIPE_SIGNATURE"
  end
end
