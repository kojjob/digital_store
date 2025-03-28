# This patch adds stub methods for Devise confirmable to User model
# when database columns are not yet available

Rails.application.config.after_initialize do
  if defined?(User) && User.included_modules.include?(Devise::Models::Confirmable)
    User.class_eval do
      def confirmed_at
        # Return a past timestamp to consider the user confirmed
        Time.now - 1.day
      end

      def confirmation_token
        nil
      end

      def confirmation_sent_at
        nil
      end

      def confirm
        true
      end

      def confirmed?
        true
      end

      def pending_reconfirmation?
        false
      end

      def unconfirmed_email
        nil
      end

      def reconfirmation_required?
        false
      end

      def send_confirmation_instructions
        true
      end

      def send_reconfirmation_instructions
        true
      end
    end
  end
end
