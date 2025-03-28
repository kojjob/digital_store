# frozen_string_literal: true

class MomoWebhooksController < ApplicationController
  # Skip CSRF protection for webhooks
  skip_before_action :verify_authenticity_token
  # Skip authentication for webhook endpoints
  skip_before_action :authenticate_user!

  def create
    provider = params[:provider]&.downcase
    payload = request.body.read
    signature = request.headers['X-Momo-Signature']

    # Validate provider
    unless MomoService::PROVIDERS.key?(provider.to_sym)
      render json: { status: 'error', error: 'Invalid provider' }, status: :bad_request
      return
    end

    # Return error if signature header is missing
    unless signature
      render json: { status: 'error', error: 'Signature header missing' }, status: :bad_request
      return
    end

    result = MomoService.process_webhook(provider, payload, signature)

    if result[:status] == 200
      render json: { status: 'success' }, status: :ok
    else
      # Don't expose detailed error messages in response
      render json: { status: 'error' }, status: result[:status] || :bad_request
      
      # Log the actual error internally
      Rails.logger.error("MoMo webhook error: #{result[:error]}")
    end
  end
end