class ContactMailer < ApplicationMailer
  def contact_email(name, email, subject, message)
    @name = name
    @email = email
    @subject = subject
    @message = message
    
    mail(
      to: "kojcoder@gmail.com",
      subject: "Contact Form: #{@subject}",
      reply_to: @email
    )
  end
end