# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  # Skip CSRF protection for webhooks - Stripe uses signature verification instead
  skip_before_action :verify_authenticity_token
  # Skip authentication for webhook endpoints
  skip_before_action :authenticate_user!, if: -> { action_name == 'create' }

  def create
    payload = request.body.read
    signature = request.env['HTTP_STRIPE_SIGNATURE']

    # Return error if signature header is missing
    unless signature
      render json: { status: 'error', error: 'Signature header missing' }, status: :bad_request
      return
    end

    result = StripeService.handle_webhook(payload, signature)

    if result[:status] == 200
      render json: { status: 'success' }, status: :ok
    else
      # Don't expose detailed error messages in response
      render json: { status: 'error' }, status: :bad_request
      
      # Log the actual error internally
      Rails.logger.error("Stripe webhook error: #{result[:error]}")
    end
  end
end