namespace :downloads do
  desc "Send expiration notifications for download links expiring soon"
  task send_expiration_notifications: :environment do
    # Find links expiring in the next 3 days
    expiry_threshold = 3.days.from_now

    download_links = DownloadLink.active
                                .where("expires_at > ? AND expires_at < ?", Time.current, expiry_threshold)

    puts "Found #{download_links.count} download links expiring soon"

    download_links.each do |link|
      # Skip if no user or product
      next unless link.user && link.product

      # Calculate days left
      days_left = ((link.expires_at - Time.current) / 1.day).round

      puts "Sending expiration notification for link #{link.id} (#{days_left} days left)"

      # Send email notification
      OrderMailer.download_expiring(link).deliver_now
    end

    puts "Completed sending expiration notifications"
  end
end
