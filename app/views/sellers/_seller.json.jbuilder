json.extract! seller, :id, :user_id, :business_name, :description, :location, :country, :phone_number, :verified, :commission_rate, :bank_account_details, :mobile_money_details, :acceptance_rate, :average_response_time, :created_at, :updated_at
json.url seller_url(seller, format: :json)
