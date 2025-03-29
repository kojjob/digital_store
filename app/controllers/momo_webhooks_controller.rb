# frozen_string_literal: true

class MomoWebhooksController < ApplicationController
  include WebhookHandling

  def create
    provider = params[:provider]&.downcase
    payload = request.body.read
    signature = request.headers["X-Momo-Signature"]

    # Log the webhook receipt but sanitize sensitive data
    Rails.logger.info("MoMo webhook received from provider: #{provider}. Request ID: #{request.request_id}")

    # Validate provider
    unless MomoService::PROVIDERS.key?(provider.to_sym)
      log_and_respond("Invalid provider: #{provider}", :bad_request)
      return
    end

    # Return error if signature header is missing
    unless signature
      log_and_respond("Signature header missing", :bad_request)
      return
    end

    # Create an audit log entry for the webhook receipt
    create_webhook_audit_log(provider, payload)

    # Process the webhook
    result = MomoService.process_webhook(provider, payload, signature)

    if result[:status] == 200
      render json: { status: "success" }, status: :ok
    else
      # Don't expose detailed error messages in response
      render json: { status: "error" }, status: result[:status] || :bad_request

      # Log the actual error internally
      Rails.logger.error("MoMo webhook error: #{result[:error]}")
    end
  rescue => e
    # Log the error but return a generic response
    Rails.logger.error("Unexpected error in MoMo webhook processing: #{e.class.name} - #{e.message}")
    render json: { status: "error" }, status: :internal_server_error
  end

  private

  # Define the provider for the WebhookHandling concern
  def webhook_provider
    params[:provider]&.downcase || "momo"
  end

  # Define the signature header for the WebhookHandling concern
  def webhook_signature_header
    "X-Momo-Signature"
  end
end
