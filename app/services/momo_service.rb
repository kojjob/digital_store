# frozen_string_literal: true

# MoMo service for handling mobile money payment operations
class MomoService
  # Available providers
  PROVIDERS = {
    mtn: 'MTN',
    airtel: 'Airtel',
    vodafone: 'Vodafone'
  }.freeze

  # Transaction status values
  STATUS = {
    pending: 'pending',
    processing: 'processing',
    success: 'success',
    failed: 'failed'
  }.freeze

  def initialize(user)
    @user = user
  end

  # Initiate mobile money payment request
  def initiate_payment(cart, phone_number, provider)
    # Validate the provider
    unless PROVIDERS.key?(provider.to_sym)
      return { success: false, error: 'Invalid mobile money provider' }
    end

    # Validate the phone number format (basic validation)
    unless valid_phone_number?(phone_number, provider)
      return { success: false, error: 'Invalid phone number format' }
    end

    # Generate a unique transaction reference
    transaction_ref = generate_transaction_reference

    # In a real implementation, we would call the provider's API here
    # For now, we'll simulate the API call with a success response

    # Create a pending order to track this payment attempt
    order = Order.create!(
      user: @user,
      total_amount: cart.total,
      payment_processor: 'momo',
      payment_id: transaction_ref,
      payment_status: 'pending',
      status: 'pending'
    )

    # Save the phone number with the order for future reference
    order.update(payment_details: {
      phone_number: phone_number,
      provider: provider,
      initiated_at: Time.current
    }.to_json)

    # Simulate a successful payment initiation
    # In a real implementation, this would contain data from the provider's API
    {
      success: true,
      transaction_ref: transaction_ref,
      order_id: order.id,
      message: "Payment request sent to #{phone_number} via #{PROVIDERS[provider.to_sym]}. Please check your phone to complete the payment."
    }
  end

  # Verify payment status
  def verify_payment(transaction_ref)
    # Find the order by transaction reference
    order = Order.find_by(payment_id: transaction_ref, payment_processor: 'momo')
    
    if order.nil?
      return { success: false, error: 'Invalid transaction reference' }
    end

    # In a real implementation, we would call the provider's API to check the status
    # For now, we'll simulate the API call with a success response
    
    # Simulate a successful payment (80% chance of success)
    # In a real scenario, you would verify with the mobile money provider's API
    payment_successful = rand(10) < 8
    
    if payment_successful
      order.update(status: 'paid', payment_status: 'paid')
      
      # Clear the user's cart
      @user.ensure_cart.clear
      
      { 
        success: true, 
        status: 'paid',
        order_id: order.id,
        message: 'Payment completed successfully'
      }
    else
      { 
        success: false, 
        status: 'pending',
        order_id: order.id,
        message: 'Payment is still processing. Please try again later.'
      }
    end
  end

  # Process a mobile money webhook from the provider
  def self.process_webhook(provider, payload, signature)
    # Validate the webhook signature
    unless valid_webhook_signature?(provider, payload, signature)
      Rails.logger.error("SECURITY WARNING: Invalid MoMo webhook signature for provider #{provider}")
      return { status: 403, error: 'Invalid signature' }
    end

    begin
      # Parse the payload
      data = JSON.parse(payload)
      
      # Extract transaction reference
      transaction_ref = data['transaction_reference']
      transaction_status = data['status']
      
      # Find the corresponding order
      order = Order.find_by(payment_id: transaction_ref, payment_processor: 'momo')
      
      if order.nil?
        Rails.logger.error("MoMo webhook: No order found for transaction: #{transaction_ref}")
        return { status: 404, error: 'Order not found' }
      end
      
      # Update the order status based on the webhook data
      if transaction_status == 'successful'
        order.update(status: 'paid', payment_status: 'paid')
        
        # Create a download link if this is a digital product with a file
        if order.product.digital_file.attached?
          DownloadLink.create!(
            user: order.user,
            product: order.product,
            order: order,
            expires_at: 30.days.from_now,
            download_limit: 5,
            file_name: order.product.digital_file.filename.to_s,
            file_size: order.product.digital_file.byte_size,
            content_type: order.product.digital_file.content_type
          )
        end
        
        Rails.logger.info("Order ##{order.id} marked as paid via MoMo webhook")
        
        # Here you would trigger any post-payment processes
        # e.g., sending confirmation emails, generating download links, etc.
      elsif transaction_status == 'failed'
        order.update(status: 'failed', payment_status: 'failed')
        Rails.logger.info("Order ##{order.id} payment failed via MoMo webhook")
      end
      
      { status: 200 }
    rescue JSON::ParserError => e
      Rails.logger.error("MoMo webhook error - Invalid payload: #{e.message}")
      { status: 400, error: 'Invalid payload' }
    rescue => e
      Rails.logger.error("Error processing MoMo webhook: #{e.class.name} - #{e.message}")
      { status: 500, error: 'Internal error' }
    end
  end

  private

  # Generate a unique transaction reference
  def generate_transaction_reference
    "MOMO#{Time.current.to_i}#{SecureRandom.hex(4).upcase}"
  end

  # Validate phone number format based on provider
  def valid_phone_number?(phone_number, provider)
    # Strip spaces and any other characters
    cleaned_number = phone_number.to_s.gsub(/\D/, '')
    
    case provider.to_sym
    when :mtn
      # MTN Ghana numbers start with 024, 054, 055, or 059
      # Nigeria MTN starts with 0803, 0806, 0810, 0813, 0816, 0703, 0706, 0903, 0906
      cleaned_number.length >= 10
    when :airtel
      # Airtel Ghana numbers start with 026 or 056
      # Nigeria Airtel starts with 0802, 0808, 0812, 0701, 0708, 0902, 0907
      cleaned_number.length >= 10
    when :vodafone
      # Vodafone Ghana numbers start with 020 or 050
      cleaned_number.length >= 10
    else
      false
    end
  end

  # Validate webhook signature
  def self.valid_webhook_signature?(provider, payload, signature)
    # In a real implementation, this would verify the signature from the provider
    # For now, we'll simulate the verification
    return false if signature.blank?
    
    # Get the provider's webhook secret from environment variables
    webhook_secret = case provider.to_sym
                     when :mtn
                       ENV.fetch('MOMO_MTN_WEBHOOK_SECRET', nil)
                     when :airtel
                       ENV.fetch('MOMO_AIRTEL_WEBHOOK_SECRET', nil)
                     when :vodafone
                       ENV.fetch('MOMO_VODAFONE_WEBHOOK_SECRET', nil)
                     else
                       nil
                     end
    
    # Return false if the webhook secret is not configured
    return false if webhook_secret.blank?
    
    # In a real implementation, you would verify the signature here
    # For now, we'll just return true if signature is present
    true
  end
end