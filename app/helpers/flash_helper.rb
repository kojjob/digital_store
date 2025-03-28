# frozen_string_literal: true

module FlashHelper
  # Creates a flash message that can safely include HTML
  #
  # @param message [String] The message text
  # @param options [Hash] Additional options
  # @option options [String] :type The flash message type (:notice, :alert, etc.)
  # @option options [Boolean] :escape Whether to escape HTML (defaults to true)
  # @option options [Integer] :timeout Custom timeout in milliseconds
  #
  # @example Create a simple flash message
  #   flash_message("Your account was created successfully")
  #
  # @example Create an error message with HTML
  #   flash_message("Please <strong>try again</strong>", type: :error, escape: false)
  #
  # @example Create a notice with longer timeout
  #   flash_message("Important information", type: :notice, timeout: 10000)
  #
  # @return [String] The formatted message
  def flash_message(message, options = {})
    type = options[:type] || :notice
    escape = options.fetch(:escape, true)
    timeout = options[:timeout]

    # Handle HTML content
    content = escape ? ERB::Util.html_escape(message) : message

    # Store in flash with additional metadata
    flash[type] = content

    # Optionally set a custom timeout via data attribute in the controller
    # This will be picked up by the JavaScript
    flash[:_flash_metadata] ||= {}
    flash[:_flash_metadata][type] = { timeout: timeout } if timeout

    content
  end

  # Adds an action link to a flash message
  #
  # @param message [String] The message text
  # @param link_text [String] The text for the action link
  # @param url [String] The URL the link should point to
  # @param options [Hash] Additional options as in flash_message
  #
  # @example Create a flash with an undo link
  #   flash_message_with_action("Item deleted", "Undo", undo_item_path(@item), type: :notice)
  #
  # @return [String] The formatted message with action link
  def flash_message_with_action(message, link_text, url, options = {})
    link = view_context.link_to(link_text, url, class: "underline font-medium")
    full_message = "#{message} #{link}".html_safe

    # Always set escape to false since we're deliberately including HTML
    options[:escape] = false
    flash_message(full_message, options)
  end
end
