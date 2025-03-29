# frozen_string_literal: true

# Validator for phone numbers based on country and provider
class PhoneNumberValidator
  # Available providers
  PROVIDERS = {
    mtn: "MTN",
    airtel: "Airtel",
    vodafone: "Vodafone"
  }.freeze

  # Initialize with country (defaults to Ghana)
  def initialize(country: :ghana)
    @country = country.to_sym
  end

  # Validate a phone number for a specific provider
  def valid?(phone_number, provider)
    return false unless PROVIDERS.key?(provider.to_sym)
    
    # Strip spaces and any other characters
    cleaned_number = phone_number.to_s.gsub(/\D/, "")
    
    # Validate based on country and provider
    case @country
    when :ghana
      valid_ghana_number?(cleaned_number, provider)
    when :nigeria
      valid_nigeria_number?(cleaned_number, provider)
    else
      # Default to basic validation for unknown countries
      cleaned_number.length >= 10
    end
  end

  # Get country code for the initialized country
  def country_code
    case @country
    when :ghana
      "+233"
    when :nigeria
      "+234"
    else
      ""
    end
  end

  # Format a phone number to international format
  def format_international(phone_number)
    cleaned = phone_number.to_s.gsub(/\D/, "")
    
    # Remove leading zeros
    cleaned = cleaned.gsub(/^0+/, "")
    
    # Add country code
    "#{country_code}#{cleaned}"
  end

  private

  # Validate Ghana phone numbers
  def valid_ghana_number?(cleaned_number, provider)
    case provider.to_sym
    when :mtn
      # MTN Ghana numbers start with 024, 054, 055, or 059
      /^(0)(24|54|55|59)\d{7}$/.match?(cleaned_number)
    when :airtel
      # Airtel Ghana numbers start with 026 or 056
      /^(0)(26|56)\d{7}$/.match?(cleaned_number)
    when :vodafone
      # Vodafone Ghana numbers start with 020 or 050
      /^(0)(20|50)\d{7}$/.match?(cleaned_number)
    else
      false
    end
  end

  # Validate Nigeria phone numbers
  def valid_nigeria_number?(cleaned_number, provider)
    case provider.to_sym
    when :mtn
      # Nigeria MTN starts with 0803, 0806, 0810, 0813, 0816, 0703, 0706, 0903, 0906
      /^(0)(803|806|810|813|816|703|706|903|906)\d{7}$/.match?(cleaned_number)
    when :airtel
      # Nigeria Airtel starts with 0802, 0808, 0812, 0701, 0708, 0902, 0907
      /^(0)(802|808|812|701|708|902|907)\d{7}$/.match?(cleaned_number)
    else
      false
    end
  end
end
