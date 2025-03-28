# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    signature = request.env['HTTP_STRIPE_SIGNATURE']

    result = StripeService.handle_webhook(payload, signature)

    if result[:status] == 200
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'error', error: result[:error] }, status: :bad_request
    end
  end
end