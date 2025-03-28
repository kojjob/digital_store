ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers if defined?(Devise)

    # Helper method to safely check if a table exists without causing exceptions
    def self.table_exists?(table_name)
      begin
        ActiveRecord::Base.connection.tables.include?(table_name.to_s)
      rescue
        false
      end
    end
  end
end

# Define assigns method for controller tests
# This is needed because assigns was removed in Rails 5
module ActionController
  class TestCase
    def assigns(key = nil)
      if key.nil?
        @controller.view_assigns
      else
        @controller.view_assigns[key.to_s]
      end
    end
  end
end

# Apply assigns to integration tests too
module ActionDispatch
  class IntegrationTest
    def assigns(key)
      @controller.instance_variable_get("@#{key}")
    end
  end
end
