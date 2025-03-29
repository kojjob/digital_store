# frozen_string_literal: true

# Centralized configuration for payment services
module PaymentConfig
  # MoMo configuration settings
  module MoMo
    # Get webhook secret for a specific provider
    def self.webhook_secret(provider)
      case provider.to_s.downcase
      when "mtn"
        get_secret("momo", "mtn_webhook_secret", "MOMO_MTN_WEBHOOK_SECRET")
      when "airtel"
        get_secret("momo", "airtel_webhook_secret", "MOMO_AIRTEL_WEBHOOK_SECRET")
      when "vodafone"
        get_secret("momo", "vodafone_webhook_secret", "MOMO_VODAFONE_WEBHOOK_SECRET")
      else
        nil
      end
    end

    # Get API key for a specific provider
    def self.api_key(provider)
      case provider.to_s.downcase
      when "mtn"
        get_secret("momo", "mtn_api_key", "MOMO_MTN_API_KEY")
      when "airtel"
        get_secret("momo", "airtel_api_key", "MOMO_AIRTEL_API_KEY")
      when "vodafone"
        get_secret("momo", "vodafone_api_key", "MOMO_VODAFONE_API_KEY")
      else
        nil
      end
    end

    # Get API endpoint for a specific provider
    def self.api_endpoint(provider, environment = Rails.env)
      case provider.to_s.downcase
      when "mtn"
        environment.production? ? "https://api.mtn.com/v1/" : "https://sandbox.mtn.com/v1/"
      when "airtel"
        environment.production? ? "https://api.airtel.com/v1/" : "https://sandbox.airtel.com/v1/"
      when "vodafone"
        environment.production? ? "https://api.vodafone.com/v1/" : "https://sandbox.vodafone.com/v1/"
      else
        nil
      end
    end

    # Get allowed webhook IPs for a specific provider
    def self.allowed_ips(provider)
      config_ips = Rails.application.config_for(:webhooks).dig(provider.to_sym, :allowed_ips)

      # Convert to an array if a string was provided
      return config_ips.split(",").map(&:strip) if config_ips.is_a?(String)

      # Return as is if it's already an array
      return config_ips if config_ips.is_a?(Array)

      # Fall back to environment variables if config is missing
      env_ips = ENV.fetch("#{provider.upcase}_WEBHOOK_ALLOWED_IPS", nil)
      return env_ips.split(",").map(&:strip) if env_ips.present?

      # Return an empty array if no configuration is found
      []
    end
  end

  # Stripe configuration settings
  module Stripe
    # Get secret key
    def self.secret_key
      get_secret("stripe", "secret_key", "STRIPE_SECRET_KEY")
    end

    # Get publishable key
    def self.publishable_key
      get_secret("stripe", "publishable_key", "STRIPE_PUBLISHABLE_KEY")
    end

    # Get webhook secret
    def self.webhook_secret
      get_secret("stripe", "webhook_secret", "STRIPE_WEBHOOK_SECRET")
    end

    # Get allowed webhook IPs
    def self.allowed_ips
      config_ips = Rails.application.config_for(:webhooks).dig(:stripe, :allowed_ips)

      # Convert to an array if a string was provided
      return config_ips.split(",").map(&:strip) if config_ips.is_a?(String)

      # Return as is if it's already an array
      return config_ips if config_ips.is_a?(Array)

      # Return Stripe's documented webhook IPs
      [
        "54.187.174.169",
        "54.187.205.235",
        "54.187.216.72",
        "3.18.12.63",
        "3.130.192.231"
      ]
    end
  end

  # Helper method to get secret from Rails credentials or env vars
  def self.get_secret(service, key, env_var = nil)
    # Try to get from credentials first (more secure)
    secret = Rails.application.credentials.dig(service.to_sym, key.to_sym)

    # Fall back to environment variable if not found in credentials
    secret || (env_var.present? ? ENV.fetch(env_var, nil) : nil)
  end
end
